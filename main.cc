#include <chrono>
#include <fstream>
#include <iostream>
#include <queue>
#include <random>
#include <stdexcept>

#include <sys/sysinfo.h>

unsigned long get_total_ram() {
    struct sysinfo i;
    sysinfo(&i);
    return i.totalram;
}

std::string get_cpu_model() {
    std::ifstream cpu("/proc/cpuinfo");
    cpu.exceptions(std::ios::failbit | std::ios::badbit);
    std::string line;
    while (std::getline(cpu, line)) {
        if (line.rfind("model name", 0) == 0) {
            // line begins with "model name"
            return line.substr(line.find(':') + 2);
        }
    }
    throw std::runtime_error("could not find CPU model name");
}

thread_local std::mt19937 rng{std::random_device()()};

/*
 * Random int in range [min, max]
 */
int rand_uniform(int min, int max) {
    if (min > max)
        throw std::invalid_argument("min <= max doesn't hold");
    return std::uniform_int_distribution(min, max)(rng);
}

class Graph {
  public:
    Graph(int n) : adjacency_list_(n) {}
    void add_edge(int u, int v) {
        adjacency_list_[u].push_back(v);
        adjacency_list_[v].push_back(u);
    }
    int order() const { return adjacency_list_.size(); }
    int size() const {
        int degree_sum = 0;
        for (auto edges : adjacency_list_)
            degree_sum += edges.size();
        // In an undirected graph, the sum of the degrees is twice the number of
        // edges
        return degree_sum / 2;
    }
    std::vector<int> &operator[](int u) { return adjacency_list_[u]; }
    const std::vector<int> &operator[](int u) const {
        return adjacency_list_[u];
    }

  private:
    std::vector<std::vector<int>> adjacency_list_;
};

class Timer {
  public:
    Timer() : start_(std::chrono::steady_clock::now()) {}
    void reset() { start_ = std::chrono::steady_clock::now(); }

    /*
     * Number of milliseconds elapsed as `double`
     */
    double elapsed() const {
        auto now = std::chrono::steady_clock::now();
        return std::chrono::duration<double, std::milli>(now - start_).count();
    }

  private:
    std::chrono::steady_clock::time_point start_;
};

/**
 * Generates a random graph with `n` vertices
 */
Graph rand_graph(int n) {
    Graph g(n);
    for (int i = 0; i < n; ++i) {
        for (int j = i + 1; j < n; ++j) {
            if (rand_uniform(1, 150) == 1)
                g.add_edge(i, j);
        }
    }

    return g;
}

void num_cc_dfs(const Graph &g, std::vector<bool> &vis, int u) {
    if (vis[u])
        return;
    vis[u] = true;
    for (auto v : g[u]) {
        num_cc_dfs(g, vis, v);
    }
}

int num_cc_dfs(const Graph &g) {
    int num_cc = 0;
    std::vector<bool> vis(g.order(), false);
    for (int u = 0; u < g.order(); ++u) {
        if (!vis[u]) {
            ++num_cc;
            num_cc_dfs(g, vis, u);
        }
    }
    return num_cc;
}

void num_cc_bfs(const Graph &g, std::vector<bool> &vis, int u) {
    std::queue<int> bfs;
    bfs.push(u);
    while (!bfs.empty()) {
        int u = bfs.front();
        bfs.pop();
        if (vis[u])
            continue;
        vis[u] = true;
        for (auto v : g[u])
            bfs.push(v);
    }
}

int num_cc_bfs(const Graph &g) {
    int num_cc = 0;
    std::vector<bool> vis(g.order(), false);
    for (int u = 0; u < g.order(); ++u) {
        if (!vis[u]) {
            ++num_cc;
            num_cc_bfs(g, vis, u);
        }
    }
    return num_cc;
}

bool is_bipartite_dfs(const Graph &g, std::vector<int> &colors, int u, int v) {
    if (colors[v] != -1) {
        if (colors[v] == colors[u])
            return false;
        else
            return true;
    }
    colors[v] = colors[u] == 0 ? 1 : 0;
    for (int w : g[v]) {
        if (!is_bipartite_dfs(g, colors, v, w))
            return false;
    }
    return true;
}

bool is_bipartite_dfs(const Graph &g, std::vector<int> &colors, int u) {
    if (colors[u] != -1)
        return true;
    colors[u] = 0;
    for (int v : g[u]) {
        if (!is_bipartite_dfs(g, colors, u, v))
            return false;
    }
    return true;
}

bool is_bipartite_dfs(const Graph &g) {
    std::vector<int> colors(g.order(), -1);
    for (int u = 0; u < g.order(); ++u) {
        if (!is_bipartite_dfs(g, colors, u))
            return false;
    }
    return true;
}

bool is_bipartite_bfs(const Graph &g, std::vector<int> &colors, int u, int v) {
    std::queue<std::pair<int, int>> q;
    q.push({u, v});
    while (!q.empty()) {
        auto [u, v] = q.front();
        q.pop();
        if (colors[v] != -1) {
            if (colors[v] == colors[u])
                return false;
            else
                return true;
        }
        colors[v] = colors[u] == 0 ? 1 : 0;
        for (int w : g[v]) {
            q.push({v, w});
        }
    }
    return true;
}

bool is_bipartite_bfs(const Graph &g, std::vector<int> &colors, int u) {
    if (colors[u] != -1)
        return true;
    colors[u] = 0;
    for (int v : g[u]) {
        if (!is_bipartite_dfs(g, colors, u, v))
            return false;
    }
    return true;
}

bool is_bipartite_bfs(const Graph &g) {
    std::vector<int> colors(g.order(), -1);
    for (int u = 0; u < g.order(); ++u) {
        if (!is_bipartite_dfs(g, colors, u))
            return false;
    }
    return true;
}

enum class Algorithm {
    NumCC = 0,
    IsBipartite,
    NumAlgorithms,
};

struct Observation {
    double dfs_time;
    double bfs_time;
    Algorithm algorithm;
    int num_vertices;
    int num_edges;

    static void write_csv_header(std::ostream &os) {
        os << "dfs_time;bfs_time;algorithm;num_vertices;num_edges;total_ram;"
              "cpu_model\n";
    }
    void write_csv(std::ostream &os, unsigned long total_ram,
                   std::string cpu_model) {
        os << dfs_time << ';' << bfs_time << ';' << static_cast<int>(algorithm)
           << ';' << num_vertices << ';' << num_edges << ';' << total_ram << ';'
           << cpu_model << '\n';
    }
};

struct Experiment {
    double dfs_time, bfs_time;
};

Experiment run_experiment(const Graph &g, Algorithm a) {
    double dfs_time, bfs_time;
    Timer t;
    switch (a) {
    case Algorithm::NumCC:
        t.reset();
        num_cc_dfs(g);
        dfs_time = t.elapsed();
        t.reset();
        num_cc_bfs(g);
        bfs_time = t.elapsed();
        break;
    case Algorithm::IsBipartite:
        t.reset();
        is_bipartite_dfs(g);
        dfs_time = t.elapsed();
        t.reset();
        is_bipartite_bfs(g);
        bfs_time = t.elapsed();
        break;
    case Algorithm::NumAlgorithms:
        throw std::invalid_argument("num algorithms isn't an algorithm");
    }
    return {dfs_time, bfs_time};
}

int main() {
    unsigned long total_ram = get_total_ram();
    std::string cpu_model = get_cpu_model();
    Observation::write_csv_header(std::cout);
    constexpr int num_samples = 1000;
    for (int sample = 0; sample < num_samples; ++sample) {
        int n = rand_uniform(500, 1000);
        auto g = rand_graph(n);
        auto a = static_cast<Algorithm>(
            rand_uniform(0, static_cast<int>(Algorithm::NumAlgorithms) - 1));
        Experiment e = run_experiment(g, a);
        Observation{e.dfs_time, e.bfs_time, a, g.order(), g.size()}.write_csv(
            std::cout, total_ram, cpu_model);
        std::cerr << "\rProgress: " << sample << '/' << num_samples;
    }
    std::cerr << std::endl;
}
