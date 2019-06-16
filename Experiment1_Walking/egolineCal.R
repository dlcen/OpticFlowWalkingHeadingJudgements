egolineCal <- function(prismDeg = 10, distance = 7, itv = 0.01) {
      
      b <- tan(pi * prismDeg/180)
      pred_y <- seq(from = 0, to = distance - itv, by = itv)
      data_no <- length(pred_y)
      pred_x <- rep(0, data_no)
      pred_angles = rep(9, data_no)
      
      for (i in 2:data_no) {
            a <- pred_x[i-1] / (7 - pred_y[i-1])
            pred_x[i] <- 0.01 * ((b-a)/(1+a*b)) + pred_x[i-1]
      }
      
      egoline <- data.frame(pred_x, pred_y, pred_angles)
      return(egoline)
}