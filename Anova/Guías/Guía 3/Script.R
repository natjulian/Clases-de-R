#Pregunta 1) 


(tipegroups<-factor(rep(c("executiv","cientific"),each=4)))
(sizegroups<-factor(rep(c(2,3,4,5),times=2)))
(nideas<-c(c(18,22,31,32),c(15,23,29,33)))


(data<-data.frame(tipegroups,sizegroups,nideas))


#Gr�fico de interacci�n

library(ggplot2)
ggplot(data, aes(x=sizegroups, y=nideas, color=tipegroups, group=tipegroups)) + geom_point() + geom_line(size=1.2) +
  labs(title = "Interacci�n de tama�o de grupo y tipo de grupo en productividad", x= "Tama�o del grupo", y="Ideas", color="Tipo de grupo") + theme_classic()


# Modelo con interacci�n

contrasts(tipegroups)<-contr.sum
contrasts(sizegroups)<-contr.sum

(modelo<-aov(nideas~tipegroups*sizegroups))

anova(modelo)

#Valores ajustados

fitted(modelo)
data$nideas

#Test de tukey

#Paso 1) Extraer vectores de los coeficientes estimados para cada factor
contrasts(tipegroups)<-contr.sum
contrasts(sizegroups)<-contr.sum

aditive<-aov(nideas~tipegroups+sizegroups)
coef(aditive)


(avalues<-ifelse(tipegroups=="cientific",unname(coef(aditive)[2]),-unname(coef(aditive)[2])))
(bvalues<-ifelse(sizegroups=="2",unname(coef(aditive)[3]),ifelse(sizegroups=="3",unname(coef(aditive)[4]),ifelse(sizegroups=="4",unname(coef(aditive)[5]),-(unname(coef(aditive)[3])+unname(coef(aditive)[4])+unname(coef(aditive)[5]))))))


#Paso 2) Define Dhat

Dhat<--0.2

# En caso de tener que calcularlo:
# (Dhat<-sum(avalues*bvalues*nideas)/(sum(unique(avalues)^{2})*sum(unique(bvalues)^{2})))


#Paso 3) Definir SCAB*

SCABp<-Dhat^{2}*sum(avalues^{2}*bvalues^{2})

#Paso 4) Extraer SCA, SCB y SCT del modelo aditivo

SCA<-anova(aditive)[1,2]
SCB<-anova(aditive)[2,2]
SCT<-sum(anova(aditive)[,2])


#Paso 5) Definir SCE*

SCEp<-SCT-SCA-SCB-SCABp

#Paso 6) Definir el estad�stico Fp

(a<-length(levels(tipegroups)))   #Niveles del factor tipo
(b<-length(levels(sizegroups)))   #Niveles del factor size

Fp=(SCABp/1)/(SCEp/(a*b-a-b))

#Paso 7) Regla de decisi�n

Fp>qf(0.95,1,a*b-a-b)    #No se rechaza la hip�tesis nula

#Se tiene la hip�tesis de aditividad


#Coeficientes del modelo aditivo
summary(aditive)

coef(aditive)

levels(tipegroups)
unname(-coef(aditive)[2]) #efecto de tipegroup2

levels(sizegroups)
sum(-coef(aditive)[3:5])  #efecto de sizegroup4



#Pregunta 2) 


library(readr)
mental <- read_delim(file.choose(), 
                     ";", escape_double = FALSE, trim_ws = TRUE)


print(head(mental))

summary(mental$Age)

Bloque<-ifelse(mental$Age<=45, "Adulto Joven",ifelse(mental$Age<60,"Adulto","Adulto Mayor"))


mental$Bloque<-factor(Bloque,levels=c("Adulto Joven","Adulto","Adulto Mayor"))
  
ggplot(aes(y = Right_answers, x = Bloque, fill=Bloque), data = mental) + 
  geom_boxplot()+theme_minimal()+
  theme(axis.text.x = element_blank())+ylab("Respuestas correctas")+xlab("")+ggtitle("Comparativa rendimiento en MiniPONS por Bloque etario")


library(dplyr)
mental %>% group_by(Bloque) %>% summarise(Media=mean(Right_answers),Minimo=min(Right_answers),Maximo=max(Right_answers),n=n())


pairwise.t.test(x = mental$Right_answers, g = mental$Bloque, p.adjust.method = "bonferroni", pool.sd = TRUE,  alternative = "two.sided")


#se espera que la variable bloque sea significativa


#b) Caso no balanceado

table(mental$Bloque,mental$Type)

addmargins(table(mental$Bloque,mental$Type))


#c) Modelo con interacci�n
mental$Type<-factor(mental$Type)

contrasts(mental$Bloque)<-contr.sum
contrasts(mental$Type)<-contr.sum

modelfull<-aov(Right_answers~Bloque*Type,data=mental)

anova(modelfull)

#La interacci�n no es signifcativa



#d) Interpretaci�n de coeficientes


contrasts(mental$Bloque)<-contr.sum
contrasts(mental$Type)<-contr.sum

aditivo<-aov(Right_answers~Type+Bloque,data=mental)

coef(aditivo)

levels(mental$Type)

sum(-coef(aditivo)[2:4])  #efecto de estado psiquico UD

levels(mental$Bloque)

sum(-coef(aditivo)[5:6])  #efecto asociado a rango etario Adulto mayor


#prueba post-hoc

round(TukeyHSD(aditivo)$Type,5)



#e) An�lisis de supuestos

par(mfrow=c(1,4))

plot(residuals(aditivo), fitted(aditivo), main="Ajustados vs residuos",xlab="Residuos",ylab="Ajustados")

qqnorm(residuals(aditivo),main="Gr�fico cuantil-cuantil de residuos",xlab="Cuantiles te�ricos distribuci�n normal",ylab="Cuantiles de los residuos")
qqline(residuals(aditivo))

boxplot(residuals(aditivo),main="Boxplot de los residuos")
boxplot(residuals(aditivo)~mental$Bloque,xlab="Bloque etario",main="Boxplot de los residuos por bloque")
