### ALGORITMO EM PARA IMPUTACI�N DE CASOS FALTANTES

####### CASO NORMAL BIVARIADA


load(file.choose()) #Carga el archivo Colesterol.RData

head(colesterol)

class(colesterol) #De tipo matrix

colesterol<-data.frame(colesterol)

colnames(colesterol)<-c("2 d�as","14 d�as")

head(colesterol)

### VISUALIZACION DE INCERTIDUMBRE (DATOS FALTANTES)

#install.packages("naniar")
library(naniar)

vis_miss(colesterol)

vis_miss(colesterol, sort_miss = TRUE) #Muestra primero las variables con m�s datos faltantes

#El registro realizado a los 14 d�as posee mayor cantidad de datos faltantes con un 32.14%
#El registro realizado a los 2 d�as posee 7.14% de datos faltantes

#install.packages("VIM")
library(VIM)

#Este paquete personalmente me gusta m�s, porque muestra los casos

#Cuando existen datos faltantes es importante preguntarse:

#�Faltan ambas mediciones? �Solo una u otra?

aggr(colesterol)
aggr(colesterol, numbers=TRUE) #Muestra los porcentajes para cada caso

aggr(colesterol,col=c('maroon','rosybrown3'), combined=TRUE, numbers=TRUE) 

#Se puede observar que existe una no menor parte de observaciones faltantes
#para la medici�n a los 14 d�as, siendo m�s de la mitad de los 
#registros completos.

#En este caso, s�lo falta una u otra medici�n, pero nunca ambas, por lo tanto, 
#En el algoritmo EM tendremos habr�n dos casos:

# - �Falta la observaci�n de 2 d�as? o �Falta la observaci�n de 14 d�as?

# No existe ningun caso donde falten ambas as� que no se incluir� ese caso


#IMPLEMENTACI�N

#### FORMA 1:

EMnormal<-function(datos,mu1,mu2,sigma1,sigma2,rho,N){
  n<-dim(datos)[1]
  
  M=cbind(datos,rep(0,n),rep(0,n))
  
  for(k in 1:N){
    #Paso E, reemplazar por la esperanza condicional: imputar
    
    for(i in 1:n){
      if(is.na(datos[i,1])==TRUE){ #Si la primera medicion es faltante
        M[i,1]<-mu1+rho*sigma1/(sigma2)*(datos[i,2]-mu2) #E(Y_i1|Y_i2,theta)
        M[i,3]<-(1-rho^{2})*sigma1^{2} #Var(Y_i1|Y_i2,theta)
      }
      
      if(is.na(datos[i,2])==TRUE){ #Si la segunda medicion es faltante
        M[i,2]<-mu2+rho*sigma2/(sigma1)*(datos[i,1]-mu1) #E(Y_i2|Y_i1, theta)
        M[i,4]<-(1-rho^{2})*sigma2^{2} #Var(Y_i2^{2}|Y_i1, theta)
      }
    }
    
    #Notar que ya tenemos Y completo pues imputamos los datos faltantes
    
    #Paso M, utilizar los estimadores maximo verosimil y actualizar par�metros
    
    mu1<-sum(M[,1])/n 
    mu2<-sum(M[,2])/n 
    sigma1<-sqrt((sum(M[,1]^{2}+M[,3]))/n-mu1^{2})
    sigma2<-sqrt((sum(M[,2]^{2}+M[,4]))/n-mu2^{2})
    rho<-((sum(M[,1]*M[,2]))/n-mu1*mu2)/(sigma1*sigma2)
  }
  
  M<-M[,1:2]
  
  return(list=c("media1"=mu1,"media2"=mu2,"sd1"=sigma1,"sd2"=sigma2,
                "rho"=rho,"datos"=M))
}


#### VALORES INICIALES: theta^{(0)}


mu1<-mean(colesterol$`2 d�as`, na.rm = TRUE)
mu2<-mean(colesterol$`14 d�as`, na.rm=TRUE)
sigma1<-sd(colesterol$`2 d�as`, na.rm=TRUE)
sigma2<-sd(colesterol$`14 d�as`, na.rm = TRUE)
rho<-cor(na.omit(colesterol))[1,2]


#### ITERACIONES
(d<-EMnormal(colesterol,mu1, mu2, sigma1, sigma2, rho,1000))

d$`datos.2 d�as`
d$`datos.14 d�as`

#### FORMA 2

library(dplyr)

EMnormalfast<-function(datos,mu1,mu2,sigma1,sigma2,rho,N){
    for(i in 1:N){
        datosimputados<- datos%>%
             mutate(Ey1=ifelse(is.na(`2 d�as`)==TRUE, mu1+rho*sigma1/(sigma2)*(`14 d�as`-mu2), 0), 
                Ey2=ifelse(is.na(`14 d�as`)==TRUE, mu2+rho*sigma2/(sigma1)*(`2 d�as`-mu1), 0), 
                VarY1=ifelse(is.na(`2 d�as`)==TRUE, (1-rho^{2})*sigma1^{2}, 0),
                VarY2=ifelse(is.na(`14 d�as`)==TRUE, (1-rho^{2})*sigma2^{2}, 0))

        params<-datosimputados  %>%
             summarise(mu1=sum(`2 d�as`, Ey1, na.rm = TRUE)/length(Ey1), 
                mu2=sum(`14 d�as`, Ey2, na.rm = TRUE)/length(Ey1), 
                sigma1=sqrt(sum(`2 d�as`^{2}, Ey1^{2}, VarY1, na.rm = TRUE)/length(Ey1)-mu1^{2}), 
                sigma2=sqrt(sum(`14 d�as`^{2}, Ey2^{2}, VarY2, na.rm = TRUE)/length(Ey1)-mu2^{2}), 
                rho=(sum(`2 d�as`*`14 d�as`,Ey1*`14 d�as`,Ey2*`2 d�as`,na.rm=TRUE)/length(Ey1)-mu1*mu2)/(sigma1*sigma2))

mu1<-params$mu1
mu2<-params$mu2
sigma1<-params$sigma1
sigma2<-params$sigma2
rho<-params$rho

  }
 datosimputados[which(is.na(datos$`2 d�as`)==TRUE), 1]<-datosimputados[which(is.na(datos$`2 d�as`)==TRUE), "Ey1"]
 datosimputados[which(is.na(datos$`14 d�as`)==TRUE), 2]<-datosimputados[which(is.na(datos$`14 d�as`)==TRUE), "Ey2"]
 

return(list=c("media1"=mu1,"media2"=mu2,"sd1"=sigma1,"sd2"=sigma2,
              "rho"=rho,"datos"=datosimputados[, 1:2]))
}


EMnormalfast(colesterol,mu1, mu2, sigma1, sigma2, rho,1000)


### �COMPARACION?

library(microbenchmark) #Calcula el tiempo de ejecucion en milisegundos

mbm <- microbenchmark(
  "For and if" = {EMnormal<-function(datos,mu1,mu2,sigma1,sigma2,rho,N){
  n<-dim(datos)[1]
  
  M=cbind(datos,rep(0,n),rep(0,n))
  
  for(k in 1:N){
    
    for(i in 1:n){
      if(is.na(datos[i,1])==TRUE){ 
        M[i,1]<-mu1+rho*sigma1/(sigma2)*(datos[i,2]-mu2) 
        M[i,3]<-(1-rho^{2})*sigma1^{2} 
      }
      
      if(is.na(datos[i,2])==TRUE){ 
        M[i,2]<-mu2+rho*sigma2/(sigma1)*(datos[i,1]-mu1) 
        M[i,4]<-(1-rho^{2})*sigma2^{2} 
      }
    }

        mu1<-sum(M[,1])/n 
    mu2<-sum(M[,2])/n 
    sigma1<-sqrt((sum(M[,1]^{2}+M[,3]))/n-mu1^{2})
    sigma2<-sqrt((sum(M[,2]^{2}+M[,4]))/n-mu2^{2})
    rho<-((sum(M[,1]*M[,2]))/n-mu1*mu2)/(sigma1*sigma2)
  }
  
  M<-M[,1:2]
  
  return(list=c("media1"=mu1,"media2"=mu2,"sd1"=sigma1,"sd2"=sigma2,
                "rho"=rho,"datos"=M))
}
EMnormal(colesterol,mu1, mu2, sigma1, sigma2, rho,50)
},

"For and ifelse" = {
  library(dplyr)
  EMnormalfast<-function(datos,mu1,mu2,sigma1,sigma2,rho,N){
    for(i in 1:N){
      datosimputados<- datos%>%
        mutate(Ey1=ifelse(is.na(`2 d�as`)==TRUE, mu1+rho*sigma1/(sigma2)*(`14 d�as`-mu2), 0), 
               Ey2=ifelse(is.na(`14 d�as`)==TRUE, mu2+rho*sigma2/(sigma1)*(`2 d�as`-mu1), 0), 
               VarY1=ifelse(is.na(`2 d�as`)==TRUE, (1-rho^{2})*sigma1^{2}, 0),
               VarY2=ifelse(is.na(`14 d�as`)==TRUE, (1-rho^{2})*sigma2^{2}, 0))
      
      params<-datosimputados  %>%
        summarise(mu1=sum(`2 d�as`, Ey1, na.rm = TRUE)/length(Ey1), 
                  mu2=sum(`14 d�as`, Ey2, na.rm = TRUE)/length(Ey1), 
                  sigma1=sqrt(sum(`2 d�as`^{2}, Ey1^{2}, VarY1, na.rm = TRUE)/length(Ey1)-mu1^{2}), 
                  sigma2=sqrt(sum(`14 d�as`^{2}, Ey2^{2}, VarY2, na.rm = TRUE)/length(Ey1)-mu2^{2}), 
                  rho=(sum(`2 d�as`*`14 d�as`,Ey1*`14 d�as`,Ey2*`2 d�as`,na.rm=TRUE)/length(Ey1)-mu1*mu2)/(sigma1*sigma2))
      
      mu1<-params$mu1
      mu2<-params$mu2
      sigma1<-params$sigma1
      sigma2<-params$sigma2
      rho<-params$rho
      
    }
    datosimputados[which(is.na(datos$`2 d�as`)==TRUE), 1]<-datosimputados[which(is.na(datos$`2 d�as`)==TRUE), "Ey1"]
    datosimputados[which(is.na(datos$`14 d�as`)==TRUE), 2]<-datosimputados[which(is.na(datos$`14 d�as`)==TRUE), "Ey2"]
    
    
    return(list=c("media1"=mu1,"media2"=mu2,"sd1"=sigma1,"sd2"=sigma2,
                  "rho"=rho,"datos"=datosimputados[, 1:2]))
  }
EMnormalfast(colesterol,mu1, mu2, sigma1, sigma2, rho,50)
}
)

mbm

library(ggplot2)

#Gr�fico var�a dependiendo de la m�quina, iteraciones, etc

autoplot(mbm) + 
  theme_minimal()+
  ggtitle("Comparaci�n de funciones con 500 iteraciones")


# Ejercicio 2)

#Link interesante:

# http://varianceexplained.org/r/mixture-models-baseball/

