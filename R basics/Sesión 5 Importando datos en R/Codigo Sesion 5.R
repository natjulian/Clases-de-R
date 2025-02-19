install.packages("rio") #Instala el paquete o librer�a rio
library(rio) #Carga o llama el paquete rio

?import #Usaremos la funci�n import del paquete rio

#Los datos se guardaran en un objeto llamado datos

datos<-import(file.choose()) 

#length(.packages(all.available = TRUE)) cantidad de paquetes instalados

#file.choose abre una ventana para seleccionar la ubicaci�n del archivo

View(datos) #Vemos una vista previa de los datos

#An�lisis de la estructura de los datos:

dim(datos) #Dimensiones

names(datos) #Nombre de las variables

str(datos) #Formato de las variables

#�Cu�ntos platos hay? 
length(unique(datos$Item)) #Cuenta los nombres �nicos que hay

#�Cu�ntas categor�as hay?
length(unique(datos$Category)) #9 categor�as

## �C�mo se distribuyen los platos en las categor�as?

table(datos$Category)

df<-data.frame(table(datos$Category)) #Guarda los datos de la tabla de manera vectorizada
       
df[which.max(df$Freq),] #�Cu�l categor�a tiene m�s productos?

df[which.min(df$Freq),] #�Cu�l categor�a tiene menos productos?

df[order(df$Freq, decreasing=TRUE),] #Muestra las categor�as ordenadas por cantidad de productos

#################################### HASTA AQU� AVANZAMOS EN CLASES


#Tama�o de la porci�n

datos[which(datos$Category=="Breakfast"), 'Serving Size'] #Tama�o de la porcion codificada

substr(datos[which(datos$Category=="Breakfast"), 'Serving Size'], start = nchar(datos[which(datos$Category=="Breakfast"), 'Serving Size'])-5, stop=nchar(datos[which(datos$Category=="Breakfast"), 'Serving Size'])-3)

sizebreakfast<-as.numeric(substr(datos[which(datos$Category=="Breakfast"), 'Serving Size'], start = nchar(datos[which(datos$Category=="Breakfast"), 'Serving Size'])-5, stop=nchar(datos[which(datos$Category=="Breakfast"), 'Serving Size'])-3))

range(sizebreakfast) #Rango de valores en gramos

#Pero quiero realizar el an�lisis conociendo el nombre del producto...

productosbreakfast<-data.frame(datos$Item[which(datos$Category=="Breakfast")], sizebreakfast)

head(productosbreakfast)

names(productosbreakfast)<-c("Producto", "Porcion")

head(productosbreakfast)

#�Cu�l es el producto en el desayuno con menor porcion en gramos?

productosbreakfast[which.min(productosbreakfast$Porcion),] #Sausage McMuffin con 111 gramos

#�Cu�l es el producto en el desayuno con mayor porcion en gramos?

productosbreakfast[which.max(productosbreakfast$Porcion),] #Big Breakfast with Hotcakes and Egg Whites con 437 gramos

#�Cu�l es la mediana del tama�o de la porcion de estos productos?

summary(productosbreakfast$Porcion)

#�Qu� productos est�n bajo la mediana en tama�o de porcion en gramos?

productosbreakfast$Producto[which(productosbreakfast$Porcion<median(productosbreakfast$Porcion))]
