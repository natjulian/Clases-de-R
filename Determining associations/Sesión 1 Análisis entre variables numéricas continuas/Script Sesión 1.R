### Cargando la data

library(readr)
breast_cancer <- read_delim("breast-cancer.csv", 
                            ";", escape_double = FALSE, trim_ws = TRUE)
#An�lisis inicial de una data en R


View(breast_cancer)    #Muestra la data en una ventana aparte

head(breast_cancer,4)  #Muestra los primeros 4 registros de una data

tail(breast_cancer,4)  #Muestra los �ltimos 4 registros de una data

dim(breast_cancer)     #Entrega un vector de: n�mero de filas (registros) 
                       #n�mero de columnas (variables) de la data

nrow(breast_cancer)    #Entrega s�lo el n�mero de filas (registros) de la data

ncol(breast_cancer)    #Entrega s�lo el n�mero de columnas (variables) de la data

names(breast_cancer)   #Entrega el nombre de las variables de la data

colnames(breast_cancer) #Entrega el nombre de las variables de la data

str(breast_cancer)      #Indica formato de cada una de las variables de la data

summary(breast_cancer)  #Entrega un resumen estad�stico de cada variable


#Conclusiones inciales de la data: 

#Variable id corresponde a un identificador

table(breast_cancer$id)   #Cada id aparece una y s�lo una vez, no precisa an�lisis

table(table(breast_cancer$id)) #Duda clase pasada

#Variable diagnosis indica el diagn�stico del tumor, es la �nica variable cualitativa
#de la base de datos

table(breast_cancer$diagnosis)

#Crearemos una matriz de las variables cuantitativas:

numvar<-breast_cancer[ , -c(1,2)]   #Quitamos las dos primeras columnas
View(numvar)


#�C�mo verificar que efectivamente se quitaron las dos columnas? 
# Comparando las dimensiones

dim(breast_cancer)

dim(numvar)


#Notar que todas las variables num�ricas de la data son de tipo cuantitativas continuas


#Cuantificando la relaci�n entre variables cuantitativas

#### Covarianza

cov(numvar)    #Matriz de varianzas-covarianzas

head(cov(numvar))

#### Correlaci�n de Pearson: Medida de relaci�n entre variables cuantitativas continuas

cor(numvar)    #Matriz de correlaci�n de Pearson

head(cor(numvar))


##### Primera sesi�n llega hasta aqu� 





#aplicaci�n entre dos variables

#radius_mean: mean of distances from center to points on the perimeter
#perimeter_mean: mean size of the core tumor

#Tiene sentido que est�n relacionadas positivamente, verifiquemoslo:

cov(numvar$radius_mean,numvar$perimeter_mean)








#La covarianza entre las variables es positiva, por lo cual, existe una asociaci�n 
# positiva, si una aumenta, la otra tambi�n

#No se puede comentar sobre el grado de asociaci�n mirando la varianza, pero s� mirando 
# la correlaci�n de Pearson:

cor(numvar$radius_mean,numvar$perimeter_mean)

#La correlaci�n es pr�cticamente 1, por lo cual, se estar�a viendo una relaci�n lineal
# pr�cticamente perfecta entre ambas variables y de tipo positiva


#Gr�fico de dispersi�n b�sico entre radius_mean y perimeter_mean

plot(numvar$radius_mean,numvar$perimeter_mean,main="Relaci�n entre radius mean y perimeter mean",xlab="Radius mean",ylab="Perimeter mean",las=1)

#Gr�fico de dispersi�n mejorado entre radius_mean y perimeter_mean

#Necesitaremos instalar el paquete ggplot2
install.packages("ggplot2")

#Carga el paquete
library(ggplot2)

graph<-ggplot(numvar, aes(x = radius_mean, y = perimeter_mean))+geom_point()+
  ggtitle("Relaci�n entre radius mean y perimeter mean")+xlab("Radius mean")+
  ylab("Perimeter mean")+labs(subtitle="Diagnosis for breast cancer")+theme_minimal()+theme(
    plot.title = element_text(color = "red", size = 13, face = "bold"))

graph  #Muestra el grafico


#Le agregamos una recta que represente la relaci�n lineal entre ambas variables

graph+geom_smooth(method='lm', formula= y~x,col="red")


#La recta se ajusta casi perfectamente, los puntos que no est�n sobre la 
# recta son los que provocan que la correlaci�n de pearson no sea igual a 1



#Correlaci�n de Spearman

cor(numvar$radius_mean,numvar$perimeter_mean)

cor(numvar$radius_mean,numvar$perimeter_mean,method="spearman")

#Cuando existe una fuerte asociaci�n lineal, Pearson y Spearman 
# entregan resultados muy similares. 
#Pues una relacion lineal es monotonica.
#Pero no toda relacion monotonica es lineal.


graph<-ggplot(numvar, aes(x = radius_mean, y = perimeter_mean))+geom_point()+
  ggtitle("Relaci�n entre radius mean y perimeter mean")+xlab("Radius mean")+
  ylab("Perimeter mean")+labs(subtitle="Diagnosis for breast cancer")+theme_minimal()+theme(
    plot.title = element_text(color = "red", size = 13, face = "bold"))

graph  #Muestra el grafico



##### Sesi�n 2 llega hasta aqu�



###Ejemplo

# compactness_meanmean of perimeter^2 / area - 1.0

# concavity_meanmean of severity of concave portions of the contour

metodo_A<-breast_cancer$compactness_mean
metodo_B<-breast_cancer$concavity_mean

summary(metodo_A)

summary(metodo_B)

cov(metodo_A,metodo_B)

cor(metodo_A,metodo_B)

cor(metodo_A,metodo_B,method="spearman")


#Grafico de dispersi�n


library(ggplot2)

ggplot(data = datos, mapping = aes(x = metodo_A, y = metodo_B)) +
  geom_point(color = "black", size = 1) +
  labs(title = "Diagrama de dispersi�n", x = "m�todo A", y = "m�todo B") +
  geom_smooth(method = "lm", se = TRUE, color = "blue", lwd = 0.5) +
  geom_abline(intercept = 0, slope = 1, lwd = 0.7, col = "red") +
  theme(axis.line = element_line(colour = "black"), 
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), 
        panel.border = element_blank(), 
        panel.background = element_blank()) +
  theme_bw() + theme(plot.title = element_text(hjust = 0.5))


#Gr�fico de Bland Altman

###Concordancia

diferencia <- metodo_A - metodo_B
media <- (metodo_A + metodo_B) / 2
porcentaje <- ((diferencia / media) * 100)
datos <- data.frame(metodo_A, metodo_B, diferencia, media, porcentaje)

#Grafico de Bland y Altman

install.packages("BlandAltmanLeh")

library(BlandAltmanLeh)
bland.altman.plot(metodo_A, metodo_B, main = "Bland-Altman Plot", 
                  xlab = "media m�todo A y m�todo B", 
                  ylab = "m�todo A - m�todo B", conf.int = .95)


##### Sesi�n 3 llega hasta aqu�

