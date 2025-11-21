#include <chrono>
#include <iostream>
#include <queue>
#include <random>
#include <stdexcept>

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
     * Number of seconds elapsed as `double`
     */
    double elapsed() const {
        auto now = std::chrono::steady_clock::now();
        return std::chrono::duration<double>(now - start_).count();
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
            if (rand_uniform(0, 1) == 0)
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

int main() {
    for (int sample = 0; sample < 100; ++sample) {
        int n = rand_uniform(500, 1000);
        auto g = rand_graph(n);
        Timer t;
        std::cout << num_cc_dfs(g) << '\n';
        std::cerr << "Dfs took " << t.elapsed() << " seconds\n";
        t.reset();
        std::cout << num_cc_dfs(g) << '\n';
        std::cerr << "Bfs took " << t.elapsed() << " seconds\n";
    }
}
