align <- function( err, raw_x, raw_z, targetDistance = 7){
  datLen 	<- length(err)
  dz  		<- diff(raw_z)
  z 		<- raw_z - raw_z[1]
  x 		<- rep(0, datLen)
  
  for (i in 2:datLen) {
    alpha 	<-  (err[i-1] * pi)/180 - atan(x[i-1]/(targetDistance-z[i-1]))
    dx 		  <-  dz[i-1] * tan(alpha)
    x[i] 		<-  x[i-1] + dx
  }

  return(x)

}