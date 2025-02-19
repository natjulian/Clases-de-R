#### Regresi�n Lineal


#Carga la data

library(readr)
Happyness <- read_csv(file.choose())
View(Happyness)


######### An�lisis previo

puntaje=Happyness$Score   #Variable respuesta

gdp=Happyness$`GDP per capita` #Variable explicativa

summary(puntaje)

summary(gdp)

cov(puntaje,gdp)   #Asociaci�n positiva
cor(puntaje,gdp)   #Correlaci�n lineal es alta

cor(puntaje,gdp,method="spearman") 

#Correlaci�n de pearson y spearman son muy similares


#Gr�fico de dispersi�n

#install.packages("ggplot2")

library(ggplot2)

df<-data.frame(puntaje,gdp)

graph<-ggplot(df, aes(x = gdp, y = puntaje))+geom_point()+
  ggtitle("Relaci�n entre puntajes de percepci�n de felicidad y producci�n econ�mica")+xlab("gdp per capita")+
  ylab("Puntajes Percepci�n de felicidad")+labs(subtitle="Estudio internacional a�o 2019")+theme_minimal()+theme(
    plot.title = element_text(color = "red", size = 13, face = "bold"))

graph


#Se le a�ade la recta:
graph+geom_smooth(method='lm', formula= y~x,col="red",se = FALSE)



##### Regresi�n lineal simple puntajes~gdp

#Con intercepto

linealsimple<-lm(puntaje~gdp)

linealsimple

coef(linealsimple)   #Coeficientes estimados

vcov(linealsimple)  #Matriz de varianzas covarianzas


summary(linealsimple)   #Resumen del modelo

mean(residuals(linealsimple))  #practicamente cero


boxplot(residuals(linealsimple))  #hay un outlier, ser�a interesante de estudiar


##### Sesi�n 22 de Mayo llega hasta aqu�


#Testeemos b1 (la pendiente)

estimacionbeta1<-coef(linealsimple)[2]

desviacionbeta1<-sqrt(vcov(linealsimple)[2,2])

tbeta1<-estimacionbeta1/desviacionbeta1

n<-nrow(Happyness)    #cantidad de observaciones
k<-1                  #cantidad de variables a utilizar (en este caso es gdp)

pt(-abs(tbeta1),df=(n-k-1)) #valor p menor que 0.05

# se rechaza que beta1 sea cero

#Estos valores coinciden con el summary:

summary(linealsimple)


##Outliers

boxplot(residuals(linealsimple))  

#Identificando cu�l o cu�les es la observaci�n outlier:

outliers<-unname(which(residuals(linealsimple) < boxplot(residuals(linealsimple),plot=FALSE)$stats[1] | residuals(linealsimple) > boxplot(residuals(linealsimple),plot=FALSE)$stats[5]))

outliers


#Cu�l es el valor o los valores de los residuos atipicos?

residuals(linealsimple)[outliers]


#Obteniendo cantidades importantes

summary(linealsimple)$r.squared 

#Mide la proporcion de varianza de la variable dependiente explicada por la variable dependiente

#Solo utilizando la variable gdp se logra explicar un 63% de la variabilidad de los puntajes de percepcion de felicidad

summary(linealsimple)$adj.r.squared  #Ajusta el R2 por cantidad de variables



# Medidas comparativas con otros modelos: 

AIC(linealsimple)

BIC(linealsimple)  #Penaliza por el n�mero de variables explicativas

logLik(linealsimple)  #Logverosimilud


confint(linealsimple)  #Intervalo de confianza de betas


residuals(linealsimple)  #errores estimados

fitted(linealsimple)  #Estimaciones de los puntajes

#Los valores sobre la recta (estimacion usando la recta)


#Verificaci�n de supuestos


#Normalidad de ei

#install.packages("ggpubr")
library(ggpubr)
ggqqplot(residuals(linealsimple),main="Gr�fico cuantil-cuantil de residuos",xlab="Cuantiles te�ricos distribuci�n normal",ylab="Cuantiles de los residuos")


#Test de normalidad

shapiro.test(residuals(linealsimple))

#No se rechaza la hip�tesis nula de normalidad


#Homocedasticidad de ei

residuos<-residuals(linealsimple)
ajustados<-fitted(linealsimple)

df<-data.frame(residuos,ajustados)

graph<-ggplot(df, aes(x = residuos, y = ajustados))+geom_point()+
  ggtitle("Valores ajustados vs residuos del modelo")+xlab("Residuos")+
  ylab("Valores ajustados")+labs(subtitle="Regresi�n lineal simple puntajes ~ gdp")+theme_minimal()+theme(
    plot.title = element_text(color = "red", size = 13, face = "bold"))

graph

#No se observa un mayor problema de heterocedasticidad, aunque s� hay algunos 
#cambios, es necesario realizar un test

library(lmtest)
bptest(linealsimple) 

#Utilizando un 95% de confianza, no se rechaza la hip�tesis de homocedasticidad

library(car)
spreadLevelPlot(linealsimple)

#Si el valor es cercano a 1, entonces no habr�an mayores problemas de
#heterocedasticidad


#Dependencia de las observaciones

durbinWatsonTest(linealsimple)

#Testea autocorrelacion residual rho, si es cero no existir�a una
#gran dependencia residual



### Sesi�n termina aqu� 




####### REGRESI�N LINEAL M�LTIPLE

corruption<-Happyness$`Perceptions of corruption`

cor(puntaje,gdp)

cor(puntaje,corruption)

cor(gdp,corruption)


df<-data.frame(puntaje,gdp,corruption)


#Graficos

library(ggplot2)

graph<-ggplot(df, aes(x = gdp, y = puntaje))+geom_point()+
  ggtitle("Percepci�n de satisfacci�n y producci�n econ�mica")+xlab("gdp per capita")+
  ylab("Puntajes percepci�n de satisfacci�n")+labs(subtitle="Estudio internacional a�o 2019")+theme_minimal()+theme(
    plot.title = element_text(color = "red", size = 11, face = "bold"))


graph2<-ggplot(df, aes(x = corruption, y = puntaje))+geom_point()+
  ggtitle("Puntajes de percepci�n de satisfacci�n y percepci�n de corrupci�n")+xlab("Percepci�n de corrupci�n")+
  ylab("Puntajes percepci�n de satisfacci�n")+labs(subtitle="Estudio internacional a�o 2019")+theme_minimal()+theme(
    plot.title = element_text(color = "red", size = 11, face = "bold"))


#install.packages("ggpubr")

library(ggpubr)
plot<-ggarrange(graph, graph2, ncol=2)

annotate_figure(plot,top=text_grob("Relaci�n de predictores y variable dependiente",size=22))


#Gr�fico 3D

#install.packages("plot3D")
library("plot3D")
scatter3D(gdp, corruption, puntaje, phi = 0, bty = "g",
          pch = 20, cex = 2,ticktype = "detailed",xlab="gdp",ylab="corruption",zlab="puntaje")

#install.packages("plot3Drgl")
library("plot3Drgl")
plotrgl()


#### MODELO DE REGRESI�N LINEAL MULTIPLE


multiple<-lm(puntaje~gdp+corruption)

coef(multiple)

summary(multiple)


#Comparativa entre modelos

library(broom)

freedom<-Happyness$`Freedom to make life choices`

multiple2<-lm(puntaje~gdp+freedom)

multipleall<-lm(Score~.,data = Happyness[ ,-c(1,2)])

glance(linealsimple)
glance(multiple)
glance(multiple2)
glance(multipleall)


#Selecci�n de variables


#Correlaci�n

#install.packages("corrplot")
library(corrplot)

cor<-cor(Happyness[,-c(1,2)])
corrplot(cor)

# M�s gr�ficos de correlaci�n aqu�: http://www.sthda.com/english/wiki/visualize-correlation-matrix-using-correlogram

#Sesi�n termina aqu� 


#Forward

library(MASS)

View(Happyness)

biggest<-formula(lm(Score~.,data=Happyness[,-c(1,2)]))
fwd.model = step(lm(Score ~ 1, data=Happyness[,-c(1,2)]), direction='forward', scope=biggest)
fwd.model$call

#En base al AIC, el orden de inclusi�n es:
# - GDP per capita
# - Freedom to make life choices
# - Social Support
# - Healthy life expectancy
# - Perceptions of corruption

#La variable Generosity no se incluye

summary(fwd.model)  #Todas son significativas


#Backward

bcw.model<-step(lm(Score~.,data=Happyness[,-c(1,2)]), direction="backward")

bcw.model$call

# El orden para desechar:

# - Generosidad es la primera y �nica variable que desech�


#install.packages("leaps")
library(leaps)

model_subset <- regsubsets(biggest, 
                           data=Happyness[,-c(1,2)],method="exhaustive",nbest=1)

summary(model_subset)$which

#El mejor modelo con 5 variables coincide con el obtenido en
# forward y backward


summary(model_subset)$rss  #SCR por modelo

# SCR Suma cuadr�tica residual (suma(e^{2}))
# SSR Suma cuadr�tica de la regresi�n

# SCT <- SCRegresion+SCResidual


summary(model_subset)$adjr2  #R2 ajustado por modelo
summary(model_subset)$bic  #BIC

#El modelo elegido ser� el modelo obtenido por forward, backward

df<-Happyness[,-c(1,2)]

names(df)

colnames(df)<-c("Score","gdp","Socialsupp","Healthylife","Freedom","Generosity","corruption")

#Regresi�n lineal normal

RL<-lm(Score ~gdp+Socialsupp+Healthylife+Freedom+corruption,data=df)


#Regresi�n robusta

library(MASS)

RLR<-rlm(Score ~gdp+Socialsupp+Healthylife+Freedom+corruption,data=df)

coef(RL)
coef(RLR)

#install.packages("stargazer")
library(stargazer)

stargazer(RL,RLR, type="text")

# Regresi�n lineal : Se obtiene minimizando la suma cuadr�tica de los residuos
