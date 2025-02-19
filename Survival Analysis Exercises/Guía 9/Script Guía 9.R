library(readr)
mortgage <- read_csv(file.choose())

nrow(mortgage)

table(mortgage$id)   #Recordemos que tenemos info de seguimiento/longitudinal de clientes

mortgage[which(mortgage$id=="797"),c('time', 'default_time', 'gdp_time')]

#Variables tiempo-dependientes, �cu�ndo usarlas?
# - Tratamientos cambian en el tiempo
# - Variables de exposici�n que cambian en el tiempo (tener/no tener)
# - Mediciones longitudinales a nivel ID (paciente, cliente, etc�tera)


#a) 

#Existen variables ex�genas (el valor de la covariable no es afectada por el evento)
## Ejemplo: El evento es encontrar trabajo y la covariable es el % de desempleo nacional

#Variables end�genas (el valor de la covariable s� se podr�a ver afectada por el evento)
## Ejemplo: El evento es embarazarse y la covariable es el conteo de hormonas 

#Caracterizar qu� tipo de variables tenemos es FUNDAMENTAL para especificar el modelo.
#Si incluimos variables end�genas as� tal cual, podr�amos estar concluyendo err�neamente,
#induciendo ruido.

#En este contexto, la variable gdp no se podr�a ver afectada por el incumplimiento o no 
#imcumplimiento del pago de la hipoteca! Es una variable a nivel "macro" no dependiente 
#del sujeto. Por lo tanto es ex�gena (o externa).

mortgage[which(mortgage$id=="3"),c('time', 'default_time', 'gdp_time')]

#b) 

#Los datos deben ser reestructurados de modo de tener start, stop, evento y covariable Z(t).

data<-mortgage[,c('id','time', 'default_time', 'gdp_time')]

library(dplyr)

#### Si se asume que se mir� el lapso desde 0 hasta el primer tiempo y luego de 
#### a meses

#Por ejemplo, un cliente se observ� desde el tiempo 0 hasta 25 y de ah� en adelante
#se registr� durante lapsos de un mes

data<-data %>%
  arrange(id, time)%>% #Ordenar los tiempos
  group_by(id)%>%
  mutate(ind = row_number(), #Indica el n�mero de fila
         mint=min(time), #Calculo el m�nimo tiempo observado por cliente
         maxt=max(time), #Calculo el m�ximo tiempo observado por cliente 
         stop=ifelse(time==mint, mint, time), #stop es el tiempo hasta que se observ�
         start=ifelse(time==mint, 0, stop[ind-1]-1))%>%
  select(id, start,stop,default_time, gdp_time, time)

View(data)

#c) 

library(survival) #Para la funci�n coxph

badapproach<- coxph(Surv(time, default_time) ~ gdp_time, data = data)
#Modelo PH Cox con exp(beta*x_i)  (Modelo tiempo independiente)

model <- coxph(Surv(start, stop, default_time) ~ gdp_time, data = data)
#Modelo Cox con exp(alpha*Z_i(t)) (Modelo tiempo dependiente)

summary(badapproach)
summary(model)


#Ya no se le suele llamar riesgos proporcionales porque el HR no es constante
#respecto al tiempo

#Un modelo de Cox (covariable dependiente del tiempo) comparar�a el riesgo de
#un evento por valor de gdp en cada momento del evento (t)

#Un modelo de Cox PH (covariable independiente del tiempo) compara las 
#distribuciones de sobrevivencia para incrementos de valores de gdp