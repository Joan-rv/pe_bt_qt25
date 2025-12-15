dades <- read.csv("dades.csv", sep=";", header=T)
summary(dades)

# justificació anàlisi separat dels algorismes
eix_y = range(c(dades$dfs_time, dades$bfs_time))
par(mfrow=c(1, 2))
boxplot(dfs_time ~ algorithm, data=dades, ylim=eix_y)
boxplot(bfs_time ~ algorithm, data=dades, ylim=eix_y)

# dataframes separats
d_numcc <- dades[dades$algorithm == "NumCC",]
d_numcc <- subset(dades, algorithm == "NumCC")
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


M1_dfs <- lm(log(dfs_time) ~ algorithm, data=dades)
summary(M1_dfs)
# Premises model:
# m.a.s.
# normalitat dins de cada grup -> sí
# homoscedasticitat entre grups -> no es dona
par(mfrow=c(2,2))
plot(M1_dfs,c(2,1))          		        # QQ-Norm i Standard Residuals vs. Fitted
hist(rstandard(M1_dfs),font.main=1)     # Histograma dels residus estandaritzats
plot(rstandard(M1_dfs),type="l")	      # Ordre dels residus estandaritzats

# Premises model:
# m.a.s.
# normalitat dins de cada grup -> no es dona
# homoscedasticitat entre grups -> no es dona
M1_bfs <- lm(log(bfs_time) ~ algorithm, data=dades)
summary(M1_bfs)
par(mfrow=c(2,2))
plot(M1_bfs,c(2,1))          		        # QQ-Norm i Standard Residuals vs. Fitted
hist(rstandard(M1_bfs),font.main=1)     # Histograma dels residus estandaritzats
plot(rstandard(M1_bfs),type="l")	      # Ordre dels residus estandaritzats

M1 <- lm(bfs_time - dfs_time ~ algorithm, data=dades)
summary(M1)
par(mfrow=c(2,2))
plot(M1,c(2,1))          		        # QQ-Norm i Standard Residuals vs. Fitted
hist(rstandard(M1),font.main=1)     # Histograma dels residus estandaritzats
plot(rstandard(M1),type="l")	      # Ordre dels residus estandaritzats

M2_dfs <- lm(log(dfs_time) ~ num_vertices + num_edges + cpu_model, data=d_numcc)
summary(M2_dfs)
# normalitat residus: sí, però al final no
# homoscedasticitat: sí
# linealitat: sí
# independència: sí
par(mfrow=c(2,2))
plot(M2_dfs,c(2,1))          		        # QQ-Norm i Standard Residuals vs. Fitted
hist(rstandard(M2_dfs),font.main=1)     # Histograma dels residus estandaritzats
plot(rstandard(M2_dfs),type="l")	      # Ordre dels residus estandaritzats

M2_bfs <- lm(log(bfs_time) ~ num_vertices + num_edges + cpu_model, data=d_numcc)
summary(M2_bfs)
# normalitat residus: sí, però al final no
# homoscedasticitat: sí
# linealitat: sí
# independència: sí
par(mfrow=c(2,2))
plot(M2_bfs,c(2,1))          		        # QQ-Norm i Standard Residuals vs. Fitted
hist(rstandard(M2_bfs),font.main=1)     # Histograma dels residus estandaritzats
plot(rstandard(M2_bfs),type="l")	      # Ordre dels residus estandaritzats

M3_dfs <- lm(log(dfs_time) ~ num_vertices + num_edges + cpu_model, data=d_numcc)
summary(M3_dfs)
# normalitat residus: sí, però al final no
# homoscedasticitat: sí
# linealitat: sí
# independència: sí
par(mfrow=c(2,2))
plot(M3_dfs,c(2,1))          		        # QQ-Norm i Standard Residuals vs. Fitted
hist(rstandard(M3_dfs),font.main=1)     # Histograma dels residus estandaritzats
plot(rstandard(M3_dfs),type="l")	      # Ordre dels residus estandaritzats

M3_bfs <- lm(log(bfs_time) ~ num_vertices + num_edges + cpu_model, data=d_numcc)
summary(M3_bfs)
# normalitat residus: sí, però al final no
# homoscedasticitat: sí
# linealitat: sí
# independència: sí
par(mfrow=c(2,2))
plot(M3_bfs,c(2,1))          		        # QQ-Norm i Standard Residuals vs. Fitted
hist(rstandard(M3_bfs),font.main=1)     # Histograma dels residus estandaritzats
plot(rstandard(M3_bfs),type="l")	      # Ordre dels residus estandaritzats

M4 <- lm(dfs_time - bfs_time ~ algorithm, data=dades)
summary(M4)
par(mfrow=c(2,2))
plot(M4,c(2,1))          		        # QQ-Norm i Standard Residuals vs. Fitted
hist(rstandard(M4),font.main=1)     # Histograma dels residus estandaritzats
plot(rstandard(M4),type="l")	      # Ordre dels residus estandaritzats