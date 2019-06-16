sepLR <- function (thisData){
  nRight <- with(thisData, tapply( Right, Stimulis, sum) )
  nTrials <- with(thisData, tapply( Right, Stimulis, length) )
  nLeft <- nTrials - nRight
  
  newData <- data.frame(cbind(nTrials, nRight, nLeft))
  newData$Intensity <- as.numeric(rownames(newData))
  rownames(newData) <- NULL
  
  return(newData)
}