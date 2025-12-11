dades <- read.csv("dades.csv", sep=";", header=T)
summary(dades)

# justificació anàlisi separat dels algorismes
eix_y = range(c(dades$dfs_time, dades$bfs_time))
par(mfrow=c(1, 2))
boxplot(dfs_time ~ algorithm, data=dades, ylim=eix_y)
boxplot(bfs_time ~ algorithm, data=dades, ylim=eix_y)

# dataframes separats
d_numcc <- dades[dades$algorithm == "NumCC",]
d_isbi <- dades[dades$algorithm == "IsBipartite",]


# Premisses t test:
# m.a.s. depèn de la recollida de dades
# no ens cal normalitat perquè n és gran

# dfs més ràpid per numcc
t.test(d_numcc$dfs_time - d_numcc$bfs_time)

# bfs més ràpid per isbi
t.test(d_isbi$dfs_time - d_isbi$bfs_time)

# efecte multiplicatiu: aplicar log ho arregla
library(PairedData)
x <- d_numcc$dfs_time
y <- d_numcc$bfs_time
dades_aparellades <- paired(x, y)
plot(dades_aparellades,type="BA")
x <- log(d_numcc$dfs_time)
y <- log(d_numcc$bfs_time)
dades_aparellades <- paired(x, y)
plot(dades_aparellades,type="BA")
x <- d_isbi$dfs_time
y <- d_isbi$bfs_time
dades_aparellades <- paired(x, y)
plot(dades_aparellades,type="BA")
x <- log(d_isbi$dfs_time)
y <- log(d_isbi$bfs_time)
dades_aparellades <- paired(x, y)
plot(dades_aparellades,type="BA")


# T_dfs ~ algorithm
M1_dfs <- lm(log(dfs_time) ~ algorithm, data=dades)
summary(M1_dfs)
# Premises model:
# m.a.s.
# normalitat dins de cada grup -> no es dona
# homoscedasticitat entre grups -> no es dona
par(mfrow=c(2,2))
plot(M1_dfs,c(2,1))          		        # QQ-Norm i Standard Residuals vs. Fitted
hist(rstandard(M1_dfs),font.main=1)     # Histograma dels residus estandaritzats
plot(rstandard(M1_dfs),type="l")	      # Ordre dels residus estandaritzats

# Premises model:
# m.a.s.
# normalitat dins de cada grup -> no es dona
# homoscedasticitat entre grups -> no es dona
M2_bfs <- lm(log(bfs_time) ~ algorithm, data=dades)
summary(M2_bfs)
par(mfrow=c(2,2))
plot(M1_dfs,c(2,1))          		        # QQ-Norm i Standard Residuals vs. Fitted
hist(rstandard(M1_dfs),font.main=1)     # Histograma dels residus estandaritzats
plot(rstandard(M1_dfs),type="l")	      # Ordre dels residus estandaritzats