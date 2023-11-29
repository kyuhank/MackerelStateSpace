



BootTestResults2[,2]$TrueFixedPars_transformed 



BootTestResults2[,2]$TrueFixedPars_transformed 



model=11

Low=BootTestResults2[,model]$Estim_Pars_transformed-1.96*BootTestResults2[,model]$Estim_SE_transformed
Up=BootTestResults2[,model]$Estim_Pars_transformed + 1.96*BootTestResults2[,model]$Estim_SE_transformed

coverage=apply(sweep(Low, 2, BootTestResults2[,model]$TrueFixedPars_transformed, "<") & sweep(Up, 2, BootTestResults2[,model]$TrueFixedPars_transformed, ">"), 2, sum, na.rm=T)

coverage/BootTestResults2[,model]$conv_num



apply(sweep(Low, 2, BootTestResults2[,2]$TrueFixedPars_transformed, "<") & sweep(Up, 2, BootTestResults2[,2]$TrueFixedPars_transformed, ">"), 2, sum, na.rm=T)



BootTestResults2[,2]$conv_num


BootTestResults2[,2]$conv_num




xxx=apply(BootTestResults2[,2]$Estim_Pars_transformed, 1, function(x) x>Low & x<Up )


apply(xxx,2, sum, na.rm=T)

      
boxplot(BootTestResults2[,10]$RelDiff_FixedPar)





model=5


boxplot(JitterResults[[model]]$JitEstimPars)

boxplot(BootTestResults1[,model]$Estim_Ft)
lines(BootTestResults1[,model]$TrueFt)      


boxplot(BootTestResults1[,model]$Estim_qt)
lines(BootTestResults1[,model]$Trueqt)      




lapply(1:15, function(x) plot(ProfLikeResults[[x]][[1]]) )


for(x in 1:15) {
  try(plot(ProfLikeResults[[x]][[11]]))
}









df=sdreport(ModelsEstimResults[,4]$f)

mean=summary(df, "report")[rownames(summary(df, "report"))=="Bt",1]

sd=summary(df, "report")[rownames(summary(df, "report"))=="Bt",2]


matplot(cbind(mean-1.96*sd, mean, mean+1.96*sd), type='l')




################
################


xx=seq(2, 20, 0.1)


ff=dnorm(xx, 10, 3)

shift=-3

a95=17+shift
a05=10+shift
fg=19/(19+exp(-log(361)* ( (xx-a95)/(a95-a05) ) ))

plot(x=xx,y=ff)
lines(xx,fg)

plot(x=xx,y=fg*ff/sum(fg*ff), type='l')
lines(xx,fg)




l=2
u=5

hist(l+(u-l)*invlogit(xt))

median(l+(u-l)*invlogit(xt))
mean(l+(u-l)*invlogit(xt))


xt=logit((3-l)/(u-l))+rnorm(10000, 0, 0.5) 



boxplot(BootTestResults2[,11]$Estim_Pars_transformed)

ddf=BootTestResults2[,11]$Estim_SE

tt=apply(BootTestResults2[,11]$Estim_Pars, 2, sd, na.rm=T)


boxplot(sweep(ddf,2, tt, FUN="/")-1, outline=F)



ggg=tmbprofile(ModelsEstimResults[,11]$f, name = "logsigI")

fff=tmbprofile(ModelsEstimResults[,12]$f, name = "logsigI")

plot(ggg)







model=14

negLog=ModelsEstimResults[,model]$fit$objective

negLogSim=na.omit(BootTestResults2["objectives",][[model]][1:500])

Nsim=500


2*negLog+2*( (1/Nsim)*sum(-2*(-negLogSim+negLog) ) )





qsn(0.50, DistPars[[2]][1], DistPars[[2]][2], DistPars[[2]][3])




xx=ModelsInputs[[1]]$bins

par(mfrow=c(4,5), mar=c(1,1,1,1))

models=15

for (i in 1:18) {
gg=barplot(apply(ModelsInputs[[1]]$Lengfreq_t, 2, function(x) x/sum(x) )[,i], ylim=c(0, 0.2) )

lines(x=gg[,1], y=ModelsEstimResults[,models]$f$report()$PropClt[,49+i])
}



sum(ModelsEstimResults[,11]$f$report()$PropClt[,50])


ModelsEstimResults[,11]$f$report()$PropClt[,1]




AICs=unlist(lapply(1:15, function(x) 2*ModelsEstimResults[,x]$fit$objective+2*length(ModelsEstimResults[,x]$fit$par)))

AICs-min(AICs)

hist(BootTestResults2[,12]$Estim_Pars[,"sigY"], breaks = 50)

abline(h=-0.1)

boxplot(BootTestResults2[,1]$RelDiff_FixedPar, ylim=c(-1, 1))












BootTestResults2[,model]$Sim_SSBt[,1:72]


na.omit((BootTestResults2[,model]$Sim_SSBt[,1:72]-BootTestResults2[,model]$Estim_SSBt[,1:72])^2)


apply((na.omit(BootTestResults2[,model]$Sim_SSBt[,1:72]-BootTestResults2[,model]$Estim_SSBt[,1:72])^2), 1, sum, na.rm=T)



model=15


BootTestResults2_yes=BootTestResults2

BootTestResults2_no=BootTestResults2


hist( sqrt(apply(na.omit((BootTestResults2[,model]$Sim_SSBt[,69:72]-BootTestResults2[,model]$Estim_SSBt[,69:72])^2), 1, sum, na.rm=T)/3), breaks=50)
hist( sqrt(apply(na.omit((BootTestResults2[,model]$Sim_SSBt[,69:72]-BootTestResults2[,model]$Estim_SSBt[,69:72])^2), 1, sum, na.rm=T)/3), breaks=50, add=T, col=rgb(1,0,0,alpha=0.2))


plot(ProfLikeResults[[12]]$logsigI)




model=14

hist(BootTestResults2_no[,model]$Estim_SE[,"sigI"], breaks=70)
hist(BootTestResults2_yes[,model]$Estim_SE[,"sigI"], breaks=10, add=T, col=rgb(1,0,0, alpha=0.1))





unlist(BootTestResults2_yes["conv_num",])-unlist(BootTestResults2_no["conv_num",])









matplot(t(apply(BootTestResults2_yes[,12]$RelDiff_FixedPar, 2, quantile, probs=c(0.025, 0.5, 0.975), na.rm=T)), pch=16, ylim=c(-1,2))
matlines(t(apply(BootTestResults2_no[,12]$RelDiff_FixedPar, 2, quantile, probs=c(0.025, 0.5, 0.975), na.rm=T)), pch=16)



matplot(t(apply(abs(BootTestResults2_yes[,14]$RelDiff_FixedPar), 2, quantile, probs=c(0.025, 0.5, 0.975), na.rm=T)), pch=16, ylim=c(-1,3))
matlines(t(apply(abs(BootTestResults2_no[,14]$RelDiff_FixedPar), 2, quantile, probs=c(0.025, 0.5, 0.975), na.rm=T)), pch=16)




boxplot(abs(BootTestResults2_yes[,11]$RelDiff_FixedPar), outline=F)
boxplot(abs(BootTestResults2_no[,11]$RelDiff_FixedPar), add=T, col=rgb(1,0,0, alpha=0.2))




plot(density(BootTestResults2_no[,12]$Estim_SE[,"sigY"], na.rm=T))
lines(density(BootTestResults2_yes[,12]$Estim_SE[,"sigY"], na.rm=T))

hist(BootTestResults2_no[,12]$Estim_SE[,"sigY"], breaks = 50)
hist(BootTestResults2_yes[,12]$Estim_SE[,"sigY"], breaks = 5, add=T, col=rgb(1,0,0, alpha=0.1))






model=15


hist(BootTestResults2_no[,1]$Estim_Pars[,'sigY'], breaks=30)
hist(BootTestResults2_yes[,1]$Estim_Pars[,'sigY'], breaks=30)


hist(BootTestResults2_no[,12]$Estim_Pars[,'sigI'], breaks=30)
hist(BootTestResults2_yes[,12]$Estim_Pars[,'sigI'], breaks=30)

model=10


hist(sqrt(apply(na.omit((BootTestResults2_no[,model]$Sim_SSBt[,69:72]-BootTestResults2_no[,model]$Estim_SSBt[,69:72])^2), 1, sum)/3), breaks=20)
hist(sqrt(apply(na.omit((BootTestResults2_yes[,model]$Sim_SSBt[,69:72]-BootTestResults2_yes[,model]$Estim_SSBt[,69:72])^2), 1, sum)/3), breaks=20, add=T, col=rgb(1,0,0, alpha=0.1))


hist(sqrt(apply(na.omit((BootTestResults2_no[,model]$Sim_SSBt[,69:72]-BootTestResults2_no[,model]$Estim_SSBt[,69:72])^2), 1, sum)/3), breaks=20)
hist(sqrt(apply(na.omit((BootTestResults2_yes[,model]$Sim_SSBt[,69:72]-BootTestResults2_yes[,model]$Estim_SSBt[,69:72])^2), 1, sum)/3), breaks=20, add=T, col=rgb(1,0,0, alpha=0.1))


boxplot(BootTestResults2_yes[,model]$RelDiff_FixedPar, outline=F)
abline(h=0)
boxplot(BootTestResults2_no[,model]$RelDiff_FixedPar, outline=F)


model=4
boxplot(abs(BootTestResults2_no[,model]$RelDiff_SSBt[,69:72]), outline=F)
boxplot(abs(BootTestResults2_yes[,model]$RelDiff_SSBt[,69:72]), outline=F, add=T, col=rgb(1,0,0,alpha=0.1))




quantile(sqrt(apply(na.omit((BootTestResults2_no[,model]$Sim_Ft[,69:72]-BootTestResults2_no[,model]$Estim_Ft[,69:72])^2), 1, sum)/3), na.rm=T, probs=c(0.025, 0.5, 0.975))
quantile(sqrt(apply(na.omit((BootTestResults2_yes[,model]$Sim_Ft[,69:72]-BootTestResults2_yes[,model]$Estim_Ft[,69:72])^2), 1, sum)/3), na.rm=T, probs=c(0.025, 0.5, 0.975))



boxplot( sqrt(apply(na.omit((BootTestResults2_yes[,model]$Sim_Ft[,1:72]-BootTestResults2_yes[,model]$Estim_Ft[,1:72])^2), 1, sum, na.rm=T)/72), outline=F, add=T, col=rgb(1,0,0, alpha=0.2) )




plot(BootTestResults2_no["fobjs_problem",1]$fobjs_problem[[1]]$report()$predYt)
lines(BootTestResults2_no[,1]$Sim_Yt[3,])


boxplot(BootTestResults2_yes[,12]$RelDiff_FixedPar, outline=F)
boxplot(BootTestResults2_no[,12]$RelDiff_FixedPar, outline=F)
abline(h=0.15)
abline(h=-0.15)


BootTestResults2_yes=BootTestResults2
BootTestResults2_no=BootTestResults2


plot(BootTestResults2_yes[,1]$Estim_SE[,"sigY"], BootTestResults2_yes[,1]$Estim_Pars[,"sigY"])

plot(BootTestResults2_no[,12]$Estim_SE[,"sigY"], BootTestResults2_no[,12]$Estim_Pars[,"sigY"], xlim=c(0, 1))


hist(BootTestResults2_no[,1]$Estim_SE[,"sigY"], breaks=100, ylim=c(0, 200))


hist(BootTestResults2_no[,1]$Estim_SE[,"sigY"], breaks=100, ylim=c(0, 200))


hist(BootTestResults2_no[,1]$Estim_Pars[,"sigY"], breaks=10)
hist(BootTestResults2_yes[,1]$Estim_Pars[,"sigY"], breaks=10, add=T, col=rgb(1,0,0, alpha=0.1))




library(ggplot2)

na.omit(BootTestResults2_no[,model]$Estim_Pars[,"sigY"])




pp=list()

for(i in 1:15) {
CompareEstimYt=reshape2::melt(list("No"=na.omit(BootTestResults2_no[,i]$Estim_Pars[,"sigY"]), "Yes"=na.omit(BootTestResults2_yes[,i]$Estim_Pars[,"sigY"] )))

names(CompareEstimYt)<-c("estim", "Penalty")

pp[[i]]=ggplot(data = CompareEstimYt) + geom_histogram(position="identity", aes(x=estim, fill=Penalty), bins = 50, alpha=0.5)  + xlab(bquote(hat(sigma)[Y])) +
  annotate("text", x=-Inf,y=-Inf, hjust=-0.5, vjust=-5, label=paste0("M", i) )

}
library(patchwork)

wrap_plots(pp, ncol=3, nrow=5)



#geom_vline(xintercept = BootTestResults2_no[,model]$TrueFixedPars[["sigY"]], linetype=2, col="red", linewidth=1) +
  #geom_vline(xintercept = BootTestResults2_yes[,model]$TrueFixedPars[["sigY"]], linetype=1, col="black", linewidth=0.5) +
  #geom_vline(xintercept = median(BootTestResults2_no[,model]$Estim_Pars[,"sigY"], na.rm=T), linetype=3, col="red", linewidth=1) +
  #geom_vline(xintercept = median(BootTestResults2_yes[,model]$Estim_Pars[,"sigY"], na.rm=T), linetype=1, col="blue", linewidth=0.5)

  



  #BootTestResults2_yes[,model]$TrueFixedPars



median(BootTestResults2_no[,1]$Estim_Pars[,"sigY"], na.rm=T)


which(BootTestResults2_no[,1]$Estim_Pars[,"sigY"]>0.01)

model=11

median(BootTestResults2_no[,model]$Estim_Pars[which(BootTestResults2_no[,model]$Estim_Pars[,"sigY"]>0.05),"sigY"])

median(BootTestResults2_no[,model]$Estim_Pars[,"sigY"], na.rm=T)

median(BootTestResults2_yes[,model]$Estim_Pars[,"sigY"], na.rm=T)















makeDisperMat <- function (nregions, nyears, rho=0, sd=0) {
  
  
  logitRho=-log(1/rho-1)
  
  drawlogitRho=rnorm(nyears, logitRho, sd)
  
  rho=1/(1+exp(-drawlogitRho))
  
  if(nregions>1) {
    
    disMat <- array(dim=c(nyears, nregions,  nregions))
    
    for (t in 1:nyears) {
      for (i in 1:nregions) {
        for (j in 1:nregions) {
          
          if(i==j) {
            disMat[t,i,j]=1
          } else {
            disMat[t,i,j]=1*rho[t]^(abs(i-j))
          }
          
        }
      }
      
      disMat[t,,]=sweep(disMat[t,,], 2, colSums(disMat[t,,]), "/")
    }
    
  }  else {
    
    disMat <- array(1, dim=c(nyears, 1,  1))
    
  }
  
  
  
  return(disMat)
  
}





disMat=matrix(nrow=100, ncol=100)

sig=0.2

rho=0.9

for (i in 1:100) {
  for (j in 1:100) {
    
    if(i==j) {
      disMat[i,j]=sig*sig
    } else {
      disMat[i,j]=sig^2*rho^(abs(i-j))
    }
    
  }
}


ddddd=MASS::mvrnorm(1, rep(0, 100), disMat)


xxxx=c(ddddd%*%solve(chol(disMat)))

plot(xxxx)

qqnorm(xxxx)
abline(0,1)






ModelsEstimResults[,1]$f$env$spHess()


library(TMB)
library(ggExtra)


library(ggplot2)
df <- data.frame(x = 1950:2021, y = xxx)
p <- ggplot(df, aes(x, y)) + geom_point() + theme_classic()
p
p %>% ggMarginal(margins = "y", type = "histogram", bins = 15) 

p

xxx=c(ResidTestResults[[14]]$SelResiduals[sampNum,]%*%solve(chol(disMat)))



plot(ModelsEstimResults[,2]$f$report()$Selectivity[1,], type='l')


plot( apply( apply(ModelsInputs[[1]]$LengthDist, 2, function(x) ModelsEstimResults[,2]$f$report()$Selectivity[,i]*x ), 2, sum)/max(apply( apply(ModelsInputs[[1]]$LengthDist, 2, function(x) ModelsEstimResults[,2]$f$report()$Selectivity[,i]*x ), 2, sum)) )

for ( i in 2:72) {
  lines( apply( apply(ModelsInputs[[1]]$LengthDist, 2, function(x) ModelsEstimResults[,2]$f$report()$Selectivity[,i]*x ), 2, sum)/max(apply( apply(ModelsInputs[[1]]$LengthDist, 2, function(x) ModelsEstimResults[,2]$f$report()$Selectivity[,i]*x ), 2, sum)) )
  }
  
  




ggplot(Sels, aes(Var2, Var1)) +
  geom_tile(aes(fill = value) )



ggplot(faithfuld, aes(waiting, eruptions)) +
  geom_raster(aes(fill = density))






Sels=ModelsEstimResults[,11]$f$report()$Selectivity


rownames(Sels) <- paste0(0:5)
colnames(Sels) <- paste0(1950:2021)


Sels=reshape2::melt(Sels)



library(ggplot2)
library(ggridges)


## plot
p3=ggplot(Sels, aes(x =Var1, y = Var2, height=value , group=Var2 ) ) +
  theme(legend.position = "right", panel.background = element_blank(), 
        # axis.title.x = element_text(size = 17),
        #  axis.title.y = element_text(size = 17),
        #  axis.text.x = element_text(size = 17),
        #  axis.text.y = element_text(size = 17),
        axis.line = element_line(colour = "black")
        #  legend.text = element_text(size = 17),
        #  legend.title =element_text(size = 17) 
  ) +
  geom_density_ridges(stat="identity", scale=30, alpha=0.01) 

p3



plot(Sels[1,], type='l')






Selsa05=do.call(rbind, lapply(1:15, function(x) ModelsEstimResults[,x]$f$report()$a05Residuals))


rownames(Selsa05) <- paste0("M", 1:15)
colnames(Selsa05) <- paste0(1950:2021)


Selsa05=reshape2::melt(Selsa05[c(2,5,8,11,14),])



ggplot(Selsa05, aes(x=Var2, y=value, group=Var1, color=Var1))+geom_line()












