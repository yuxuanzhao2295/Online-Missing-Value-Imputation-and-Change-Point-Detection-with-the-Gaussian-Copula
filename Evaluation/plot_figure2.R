relative_path = ''
path = paste(relative_path, 'Online-Missing-Value-Imputation-Dependence-Change-Detection-for-Mixed-Data/Evaluation', sep =  "")
setwd(path)

# read data
smaes_sim_change = array(0, dim = c(150,3,5), dimnames = list(NULL, c('cont', 'ord', 'bin'), NULL))
changes_track = array(0, dim = c(150,2))
# read EM data
data = as.matrix(read.csv("Results/simonline_EMmethods_smaes.csv"))
smaes_sim_change[,1,c(1,2)] =  data[,c(1,4)]
smaes_sim_change[,2,c(1,2)] =  data[,c(3,6)]
smaes_sim_change[,3,c(1,2)] =  data[,c(2,5)]
changes_track[,1] = as.numeric(data[,7])
# read GROUSE data
data = as.matrix(read.csv("Results/simonline_grouse_smaes.csv", header=FALSE))
smaes_sim_change[,,3] = data[,c(1,3,2)]
changes_track[,2] = as.numeric(data[,4])
# read onlineKFMC data
data = as.matrix(read.csv("Results/simonline_kfmc_smaes.csv", header=FALSE))
smaes_sim_change[,,4] = data[,c(1,3,2)]
# read missForest data
data = as.matrix(read.csv("Results/simonline_missForest_smaes.csv"))[,-1]
smaes_sim_change[,,5] = data[,c(1,3,2)]

#### preparation
names = paste(c("Continuous",  "Ordinal", 'Binary'), "Columns")

par(mar=c(4.1, 4.1, 4.1, 4.1))
index = (1:150)*40

LWD = 3
PCH = 20
#### plot imputation error
par(mfrow=c(2,2))
for (j in 1:3){
  if (j==1) r = c(0.75, 1.5)
  if (j==2) r = c(0.75, 2)
  if (j==3) r = c(0.6,1.3)
  plot(x=index, y= smaes_sim_change[,j,1], ylim = r,col='blue', cex=2,
       ylab="", main=names[j], xlab="", type='l', lty=1, lwd=LWD,font=2,cex.lab=2,cex.axis=1.5,cex.main=2)
  if (j!=2) mtext("SMAE",side=2,line=2.25,cex=1.5)
  if (j==3) mtext("Row Numbers",side=1,line=2.75,cex=1.5)
  points(x=index, y= smaes_sim_change[,j,2], col='red',  cex=1, type='l', lty=1, lwd=LWD)
  points(x=index, y= smaes_sim_change[,j,3], col='tomato3',  cex=1, type='l',lty=1, lwd=LWD)
  points(x=index, y= smaes_sim_change[,j,4], col='seagreen', cex=1, type='l',lty=1, lwd=LWD)
  points(x=index, y= smaes_sim_change[,j,5], col='burlywood', cex=1, type='l',lty=1, lwd=LWD)
  abline(h=1,lty=6, lwd=LWD)
  if (j==1){
    legend("topright", legend=c( "Online EM", "Offline EM", "GROUSE", "Online KFMC", 'missForest'),
           col=c("blue", "red", "tomato3", 'seagreen', 'burlywood'), pch=rep(PCH,5), lty=1,cex=1, lwd=LWD,text.font = 2,pt.cex=1,box.lty=0)
  }
}

#### plot subspace tracking
plot(x=index, y= changes_track[,2], ylim = range(changes_track[,2]),
     col='tomato3', cex=2, type='l', lty=1, lwd=LWD, cex.main=2, cex.axis=1.5,cex.lab=2, font=2,
     ylab="", main="Change Point Tracking ", xlab="")
par(new = TRUE)
plot(x=index, y= changes_track[,1], ylim = range(changes_track[,1]),col='blue', cex=2, type='l', lty=1, lwd=LWD,font=2, axes=FALSE, ylab="",xlab="")
axis(side = 4,cex=2, font=2, col='blue',cex.axis=1.5, at = pretty(range(changes_track[,1])))
mtext("GROUSE: Residual Norm",side=2,col="tomato3",line=2.5,cex=1.5, font=4, cex.axis=1.2)
mtext("Online EM: Correlation Change",side=4,col="blue",line=2.5,cex=1.5, font=4, cex.axis=1.2)
legend("topright", legend=c("Online EM", "GROUSE"),
       col=c("blue", "tomato3"),lty=c(2,3), cex=1,lwd=LWD,text.font=2,pt.cex=1.2, pch=20,box.lty=0)
mtext("Row Numbers",side=1,line=2.75,cex=1.5)
