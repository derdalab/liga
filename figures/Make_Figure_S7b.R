###WARNING: Running the folling script will install packages "drc", "ggplot2", and "stats".
#           Procceed with caution.


############  Clears All Data  ############
if(!is.null(dev.list())) dev.off() # Clear plots
cat("\014") # Clear console
rm(list=ls())# Clean workspace
############  Library  ##############
if(!require(drc)){
  install.packages("drc")
  library(drc)
}
if(!require(ggplot2)){
  install.packages("ggplot2")
  library(ggplot2)
}
if(!require(stats)){
  install.packages("stats")
  library(stats)
}
#############  Data input  ##############
#input the data

setwd(paste(dirname(rstudioapi::getSourceEditorContext()$path),"/LiGA data for figures", sep=""))
mydata<-read.csv("ConA_Elisa.csv", header=T)
head(mydata)

# extract subsets for the different phage-labels
man3           <- mydata[mydata$Type == "Man3", ]
Blocking_Phage <- mydata[mydata$Type == "Blocking Phage", ]
Man1           <- mydata[mydata$Type == "Man 1", ]
LNT            <- mydata[mydata$Type == "LNT", ]

fitMan3           <- drm(formula=Mean~logconc, data=man3, fct=LL.4())
fitMan1           <- drm(formula=Mean~logconc, data=Man1, fct=LL.4())
fitLNT            <- drm(formula=Mean~logconc, data=LNT, fct=LL.4())
fitBlocking_Phage <- drm(formula=Mean~logconc, data=Blocking_Phage, fct=LL.4())


plot(fitMan3, broken = TRUE, col="#0b245b", lwd=2) 
plot(fitMan1, broken = TRUE, add = TRUE, col = "#98063A", lwd=2)
plot(fitLNT, broken = TRUE, add = T, col = "#FD823E", lwd=2)
plot(fitBlocking_Phage, broken = TRUE, add = T, col = "#6C98C6", lwd=2)

ConA<-ggplot() + 
  theme_light()+
  geom_point(data = man3,aes(x = logconc, y = Mean), color="#0b245b", size=3)+
  geom_errorbar(data=man3, aes(x=logconc, ymin=Mean-Stdev_Prop, ymax=Mean+Stdev_Prop), width=.05, 
                color="black", position=position_dodge(0.05))+ 
  geom_smooth(data = man3,
              aes(x = logconc, y = Mean, col = Type),method = "lm", formula = y ~ splines::bs(x, 4), se = F, color="#0b245b")+
  geom_point(data =  Man1,aes(x = logconc, y = Mean), color="#98063A", size=3)+
  geom_errorbar(data= Man1, aes(x=logconc, ymin=Mean-Stdev_Prop, ymax=Mean+Stdev_Prop), width=.05, 
                color="black", position=position_dodge(0.05))+ 
  geom_smooth(data =  Man1,
              aes(x = logconc, y = Mean, col = Type),method = "lm", formula = y ~ splines::bs(x, 4), se = F,  color="#98063A")+
  geom_point(data =  LNT,aes(x = logconc, y = Mean), color="#FD823E", size=3)+
  geom_errorbar(data= LNT, aes(x=logconc, ymin=Mean-Stdev_Prop, ymax=Mean+Stdev_Prop), width=.05, 
                color="black", position=position_dodge(0.05))+ 
  geom_smooth(data =  LNT,
              aes(x = logconc, y = Mean, col = Type),method = "lm", formula = y ~ splines::bs(x, 4), se = F,  color="#FD823E")+
  geom_point(data =  Blocking_Phage,aes(x = logconc, y = Mean), color="#6C98C6", size=3)+
  geom_errorbar(data= Blocking_Phage, aes(x=logconc, ymin=Mean-Stdev_Prop, ymax=Mean+Stdev_Prop), width=.05, 
                color="black", position=position_dodge(0.05))+ 
  geom_smooth(data =  Blocking_Phage,
              aes(x = logconc, y = Mean, col = Type),method = "lm", formula = y ~ splines::bs(x, 4), se = F,  color="#6C98C6")+
  labs(y="Absorbance 450nm", x="Log(Pfu/mL)")+
  ggtitle("ConA - Elisa")+
  theme(axis.text.x=element_text(size=12, face="bold"),
        axis.text.y=element_text(size=9, face="bold"))
ConA
