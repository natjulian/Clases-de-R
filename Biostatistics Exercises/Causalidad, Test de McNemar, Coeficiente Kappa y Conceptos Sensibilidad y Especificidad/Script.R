#Pregunta 3)


(discusion<-matrix(c(1097,90,203,435),byrow=TRUE,ncol=2,nrow=2))


colnames(discusion)<-c("Si","No")
rownames(discusion)<-c("Si","No")

addmargins(discusion)

round(addmargins(prop.table(discusion)),3)


# Aproximado

mcnemar.test(discusion)


# Exacto

# install.packages("exact2x2")

library("exact2x2")

mcnemar.exact(discusion)


#�tem 4)

#4.2)

(screening<-matrix(c(1763,489,403,670),byrow=TRUE,ncol=2,nrow=2))

colnames(screening)<-c("Present","Absent")
rownames(screening)<-c("Present","Absent")


addmargins(screening)

# install.packages("vcd")

library(vcd)

mosaic(screening,shade=TRUE)

Kappa.test(screening)


#�tem 5)

(estrogen<-matrix(c(39,113,15,150),byrow=TRUE,ncol=2,nrow=2))

colnames(estrogen)<-c("Uso Estrogeno","No Uso Estrogeno")
rownames(estrogen)<-c("Uso Estrogeno","No Uso Estrogeno")

round(addmargins(prop.table(estrogen)),3)

mcnemar.test(estrogen) #Asint�tico


#�tem 6)

(metalurgia<-matrix(c(2,26,5,12),byrow=TRUE,ncol=2,nrow=2))

colnames(metalurgia)<-c("Ocupaci�n Metal�rgica","No ocupaci�n Metal�rgica")
rownames(metalurgia)<-c("Ocupaci�n Metal�rgica","No ocupaci�n Metal�rgica")

mcnemar.exact(metalurgia) #Test Exacto
