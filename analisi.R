dades <- read.csv("dades.csv", sep=";", header=T)
summary(dades)

eix_y = range(c(dades$dfs_time, dades$bfs_time))
par(mfrow=c(1, 2))
boxplot(dfs_time ~ algorithm, data=dades, ylim=eix_y)
boxplot(bfs_time ~ algorithm, data=dades, ylim=eix_y)

d_numcc <- dades[dades$algorithm == "NumCC",]
d_isbi <- dades[dades$algorithm == "IsBipartite",]

t.test(d_numcc$dfs_time - d_numcc$bfs_time)

t.test(d_isbi$dfs_time - d_isbi$bfs_time)

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


M1 <- lm(log(dfs_time) - log(bfs_time) ~ algorithm, data=dades)
summary(M1)
par(mfrow=c(2,2))
plot(M1,c(2,1))          		        # QQ-Norm i Standard Residuals vs. Fitted
hist(rstandard(M1),font.main=1)     # Histograma dels residus estandaritzats
plot(rstandard(M1),type="l")	      # Ordre dels residus estandaritzats

M2_numcc <- lm(log(dfs_time) ~ num_vertices + num_edges + cpu_model, data=d_numcc)
summary(M2_numcc)
par(mfrow=c(2,2))
plot(M2_numcc,c(2,1))          		        # QQ-Norm i Standard Residuals vs. Fitted
hist(rstandard(M2_numcc),font.main=1)     # Histograma dels residus estandaritzats
plot(rstandard(M2_numcc),type="l")	      # Ordre dels residus estandaritzats

M3_numcc <- lm(log(bfs_time) ~ num_vertices + num_edges + cpu_model, data=d_numcc)
summary(M3_numcc)
par(mfrow=c(2,2))
plot(M3_numcc,c(2,1))          		        # QQ-Norm i Standard Residuals vs. Fitted
hist(rstandard(M3_numcc),font.main=1)     # Histograma dels residus estandaritzats
plot(rstandard(M3_numcc),type="l")	      # Ordre dels residus estandaritzats

M2_isbi <- lm(log(dfs_time) ~ num_vertices + num_edges + cpu_model, data=d_isbi)
summary(M2_isbi)
par(mfrow=c(2,2))
plot(M2_isbi,c(2,1))          		        # QQ-Norm i Standard Residuals vs. Fitted
hist(rstandard(M2_isbi),font.main=1)     # Histograma dels residus estandaritzats
plot(rstandard(M2_isbi),type="l")	      # Ordre dels residus estandaritzats

M3_isbi <- lm(log(bfs_time) ~ num_vertices + num_edges + cpu_model, data=d_isbi)
summary(M3_isbi)
par(mfrow=c(2,2))
plot(M3_isbi,c(2,1))          		        # QQ-Norm i Standard Residuals vs. Fitted
hist(rstandard(M3_isbi),font.main=1)     # Histograma dels residus estandaritzats
plot(rstandard(M3_isbi),type="l")	      # Ordre dels residus estandaritzats