#### PARTE A) AN�LISIS PREVIO 
#Esta parte corresponde a trabajo previo de los datos para
#su an�lisis. Puede corresponder a "limpieza de datos", 
#recodificaci�n de variables, revisi�n del formato de las
#variables, determinar si no existen registros duplicados, 
#etc�tera. Esta parte no se incluye en el informe o reporte.

#a.1)

library(rio) #Cargamos la librer�a rio

anuncios<-import(file.choose()) #La funci�n import carga los datos
                                #file.choose() abre una nueva ventana 
                                #para seleccionar el archivo de datos

dim(anuncios) #Vemos la dimensi�n de la tabla de datos

names(anuncios) #Nombre de las variables, ojo con el Identificador

str(anuncios$Estacionamientos) #Revisar siempre el formato
                               #Y verificar que se lean 
                               #en el formato adecuado

table(anuncios$Estacionamientos) #Vemos que existe un valor "No"

unique(anuncios$Estacionamientos) #Valores de la variable

#Otra forma de determinar los registros que no son numericos:

as.numeric(anuncios$Estacionamientos) #Cuando aparece NA era texto

anuncios$Estacionamientos[is.na(as.numeric(anuncios$Estacionamientos))] #El valor No es el que ocasiona problemas

#Cambiamos todos los registros "No" a cero:
anuncios$Estacionamientos[which(anuncios$Estacionamientos=="No")]<-0

#Le aplicamos formato as.numeric:
anuncios$Estacionamientos<-as.numeric(anuncios$Estacionamientos)

str(anuncios$Estacionamientos) #Ahora se lee en formato num�rico! :)


#a.2)

unique(anuncios$Tipo) #S�lo toma el valor "Casa"

#a.3)

table(table(anuncios$Identificador))


#### PARTE B) AN�LISIS ESTAD�STICO

#En esta parte se realizan todos los an�lisis solicitados,
#ya nuestros datos se encuentran limpios y trabajables. 
#Esta parte va en el reporte, se trabajan estad�sticas,
#gr�ficos, tablas, entre otros, y lo m�s importante es que 
#cada recurso debe estar acompa�ado de comentarios valiosos
#e informativos.

unique(anuncios$Comuna) #Comunas con anuncios de casas en venta

table(anuncios$Comuna) #Tabla con cantidad de anuncios por comuna

comunas<-data.frame(table(anuncios$Comuna)) #Guardamos la info en una dataframe

comunas[which.max(comunas$Freq), ] #Comuna con mayor n� de anuncios de casas en venta

comunas[which.min(comunas$Freq), ] #Comuna con menor n� de anuncios de casas en venta

comunas<-comunas[order(comunas$Freq, decreasing=TRUE),] #Ordenamos de forma decreciente

head(comunas, 5) #Comunas con mas anuncios de casas en venta
tail(comunas, 5) #Comunas con menos anuncios de casas en venta

summary(comunas$Freq) #Informaci�n de la distribuci�n de anuncios

barplot(comunas$Freq) #Muestra n� de anuncios por comuna

barplot(comunas$Freq, 
        names.arg=comunas$Var1) #Le agregamos los nombres respectivos

barplot(comunas$Freq, 
        names.arg=comunas$Var1, 
        las=2) #Cambia la orientaci�n para que se vean mejor los nombres

barplot(comunas$Freq, 
        names.arg=comunas$Var1, 
        las=2,
        cex.names=0.6) #Cambio tama�o de letra de los nombres

barplot(comunas$Freq, 
        names.arg=comunas$Var1, 
        las=2,
        cex.names=0.6,
        col="lightslateblue") #A�adimos un color lindo

barplot(comunas$Freq, 
        names.arg=comunas$Var1, 
        las=2,
        cex.names=0.6,
        col="lightslateblue",
        density=15) #Un dise�o bonito

barplot(comunas$Freq, 
        names.arg=comunas$Var1, 
        las=2,
        cex.names=0.6,
        col="lightslateblue",
        density=15,
        space=0.8) #M�s espacio entre barras

barplot(comunas$Freq, 
        names.arg=comunas$Var1, 
        las=2,
        cex.names=0.6,
        col="lightslateblue",
        density=15,
        space=0.8,
        main="Anuncios de casas en venta por comuna en Mayo")

#El t�tulo jam�s debe faltar!


#install.packages("extrafont")
#library(extrafont)

#font_import()
#loadfonts()     #Importa tipos de letra de windows
#fonts()    #Muestra todos los tipos de letra

#par(family="Leelawadee UI Semilight") #Se define el tipo de letra

barplot(comunas$Freq, 
        names.arg=comunas$Var1, 
        las=2,
        cex.names=0.6,
        col="lightslateblue",
        density=15,
        space=0.8,
        main="Anuncios de casas en venta por comuna en Mayo")

#Tambi�n se pudo hacer un boxplot

boxplot(comunas$Freq,
        col="lightskyblue3", #Color
        main="N�mero de anuncios por comunas en Mayo")

summary(comunas$Freq) #Estad�sticas

#par(family="Segoe UI Symbol")

#O tambi�n un gr�fico de la funci�n de distribuci�n emp�rica
plot(ecdf(comunas$Freq), main="Funci�n de distribuci�n acumulada emp�rica", las=1, col="lightslateblue")
quantile(comunas$Freq, c(0.2, 0.4, 0.6, 0.8))

#b.2.1)

boxplot(anuncios$`Metros cuadrados`~anuncios$Comuna)

boxplot(anuncios$`Metros cuadrados`~anuncios$Comuna, 
        xlab="",
        ylab="Metros cuadrados",
        main="Metros cuadrados de casas en venta por comunas",
        las=2,
        cex.axis=0.6,
        col=rainbow(32, alpha=0.5, start=0))


### LA SESI�N 10 ACAB� AQU� 

#Pero podr�amos a�adir colores m�s informativos!

library(dplyr)

#dplyr es una librer�a S�PER �til para obtener
#estad�sticas 

anuncios%>%
  group_by(Comuna)%>% #Agrupa por comuna
  summarise(Min=min(`Metros cuadrados`)) #Para cada comuna calcula el minimo de metros cuadrados


df<-anuncios%>%
  group_by(Comuna)%>%
  summarise(Min=min(`Metros cuadrados`), #Le podemos a�adir m�s cosas!
            median=median(`Metros cuadrados`),
            Media=mean(`Metros cuadrados`),
            Max=max(`Metros cuadrados`),
            n=n()) #n() cuenta la cantidad de registros por comuna (n� de anuncios)


df #Ahora tengo una tabla con estad�sticas de metros cuadrados por comuna


# Pondremos con determinado color aquellas comunas en las que 
#se presenta mayor mediana (entre el 80% mayor) de metros cuadrados

colors<-ifelse(df$median>quantile(df$median, 0.8),  "turquoise3",
                                                    "turquoise4")

#par(family="Segoe UI Symbol")

boxplot(anuncios$`Metros cuadrados`~anuncios$Comuna,
        xlab="",
        ylab="Metros cuadrados",
        main="Metros cuadrados de casas en venta por comunas",
        col=colors,
        las=2,
        cex.axis=0.6)

#Se pueden quitar los outliers con outline=FALSE
#Lo recomiendo SOLO si quieren ver un Zoom de los datos
#Los outliers pueden ser muy importantes!

#b.2.2)

hist(df$Media)

hist(df$Media, 
     main="Histograma de los Metros Cuadrados Promedio",
     xlab="Metros cuadrados promedio",
     ylab="Frecuencia relativa",
     las=1)

hist(df$Media, 
     main="Histograma de los Metros Cuadrados Promedio",
     xlab="Metros cuadrados Promedio",
     ylab="Frecuencia relativa",
     las=1,
     breaks=30,
     freq=FALSE)

#Podemos editar los ticks de los ejes:

hist(df$Media, main="Histograma de los Metros Cuadrados Promedio",
     xlab="Metros cuadrados Promedio",
     ylab="Frecuencia relativa",
     las=1,
     breaks=30,
     freq=FALSE,
     col="cyan3",
     xlim=c(0, max(df$Media)),
     ylim=c(0, 0.016), 
     axes=FALSE)

axis(1, at=round(seq(0, max(df$Media), len=15),0), cex.axis=0.8, las=2)
axis(2, at=seq(0, 0.016, by=0.002), cex.axis=0.9, las=1)

#A�adimos la curva:
curve(dnorm(x, mean=mean(df$Media), sd=sd(df$Media)),
      col="maroon", lwd=2,add=TRUE, lty=1)

#Se observa que quiz�s los par�metros usados no sean los m�s adhoc

#Probamos con otros par�metros:
curve(dnorm(x, mean=130, sd=28), #Normal adicional
      col="navyblue", lwd=2,add=TRUE, lty=2)

legend(x=177, y=0.016,legend=c("Curva Normal media y desviaci�n emp�ricas", "Curva Normal alternativa"),
       col=c("maroon", "navyblue"),cex=0.8,pch="", bty="n", lty=1:2)



#b.3.1)

#Necesitamos calcular por comuna el promedio de habitaciones y
#el promedio de metros cuadrados

df2<-anuncios%>%
  group_by(Comuna) %>%
  summarise(muhabitaciones=mean(Habitaciones), 
            mumetros=mean(`Metros cuadrados`))

head(df2)

cor(df2$muhabitaciones,df2$mumetros) #Correlaci�n de Pearson

plot(df2$muhabitaciones, df2$mumetros)
plot(df2$muhabitaciones, df2$mumetros, 
     las=1)

plot(df2$muhabitaciones, df2$mumetros, 
     las=1, 
     xlab="Promedio de habitaciones", 
     ylab="Promedio de metros cuadrados")

plot(df2$muhabitaciones, df2$mumetros, 
     las=1, 
     xlab="Promedio de habitaciones", 
     ylab="Promedio de metros cuadrados", 
     pch=16)

plot(df2$muhabitaciones, df2$mumetros, 
     las=1, 
     xlab="Promedio de habitaciones", 
     ylab="Promedio de metros cuadrados", 
     pch=16, 
     main="Metros cuadrados y habitaciones en comunas")

plot(df2$muhabitaciones, df2$mumetros, 
     las=1, 
     xlab="Promedio de habitaciones",
     ylab="Promedio de metros cuadrados", 
     pch=16, 
     main="Metros cuadrados y habitaciones en comunas", 
     col="palevioletred4")


plot(df2$muhabitaciones, df2$mumetros, 
     las=1, 
     xlab="Promedio de habitaciones", 
     ylab="Promedio de metros cuadrados", 
     pch=16, 
     main="Metros cuadrados y habitaciones en comunas", 
     col="palevioletred4")

abline(lm(df2$mumetros~df2$muhabitaciones), 
       col="maroon1", 
       lwd=2)

text(5.8, 370, "Correlaci�n de 0.56")
