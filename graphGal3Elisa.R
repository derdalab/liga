############  Clears All Data  ############
rm(list=ls())

#############  Library  ##############
library(drc)
library(stats)
library(tidyverse)
#############  Data input  ##############
#input the data
setwd("~/Dropbox/R/Elisa_Plotting")

mydata<-read.csv("Gal3 Elisa.csv", header=T)
head(mydata)


Blocking_Phage<-filter(mydata, Type=="Blocking Phage")
Man1<- filter(mydata, Type=="Man 1")
LNT<-filter(mydata, Type=="LNT")
fitMan1<-drm(formula=Mean~logconc, data=Man1, fct=LL.4())
fitLNT<-drm(formula=Mean~logconc, data=LNT, fct=LL.4())
fitBlocking_Phage<-drm(formula=Mean~logconc, data=Blocking_Phage, fct=LL.4())




plot(fitMan1, broken = TRUE, col = "#98063A", lwd=2)
plot(fitLNT, broken = TRUE, add = T, col = "#FD823E", lwd=2)
plot(fitBlocking_Phage, broken = TRUE, add = T, col = "#6C98C6", lwd=2)

Gal3<-ggplot() + 
  theme_light()+
  geom_point(data =  Man1,aes(x = logconc, y = Mean), color="#98063A", size=3)+
  geom_errorbar(data= Man1, aes(x=logconc, ymin=Mean-Std, ymax=Mean+Std), width=.05, 
                color="black", position=position_dodge(0.05))+ 
  geom_smooth(data =  Man1,
              aes(x = logconc, y = Mean, col = Type),method = "lm", formula = y ~ splines::bs(x, 4), se = F,  color="#98063A")+
  geom_point(data =  LNT,aes(x = logconc, y = Mean), color="#FD823E", size=3)+
  geom_errorbar(data= LNT, aes(x=logconc, ymin=Mean-Std, ymax=Mean+Std), width=.05, 
                color="black", position=position_dodge(0.05))+ 
  geom_smooth(data =  LNT,
              aes(x = logconc, y = Mean, col = Type),method = "lm", formula = y ~ splines::bs(x, 5), se = F,  color="#FD823E")+
  geom_point(data =  Blocking_Phage,aes(x = logconc, y = Mean), color="#6C98C6", size=3)+
  geom_errorbar(data= Blocking_Phage, aes(x=logconc, ymin=Mean-Std, ymax=Mean+Std), width=.05, 
                color="black", position=position_dodge(0.05))+ 
  geom_smooth(data =  Blocking_Phage,
              aes(x = logconc, y = Mean, col = Type),method = "lm", formula = y ~ splines::bs(x, 4), se = F,  color="#6C98C6")+
  labs(y="Absorbance 450nm", x="Log(Pfu/mL)")+
  ggtitle("Gal3 - Elisa")+
  theme(axis.text.x=element_text(size=12, face="bold"),
        axis.text.y=element_text(size=9, face="bold"))
Gal3



