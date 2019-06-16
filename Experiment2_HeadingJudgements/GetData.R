library(xlsx); library(scales)

# Calcuate the response data for each participant (should enter to the *Data* folder)
setwd("./Data")
subjectFolders <- list.files(pattern = '^S')

scenes <- c("DotCloud", "EmptyRoom", "Line", "OutlinedRoom")
distances <- c("0m", "1m", "2m", "4m")

source("../SeparateLeftRight.R")

SbjWithLowCatchUpAccu <- NULL

for (thisSbj in subjectFolders) {
    setwd(thisSbj)
    sbjInfo <- strsplit(thisSbj, split = "_")
    sbjNo <- sbjInfo[[1]][1]
    sbjOrder <- sbjInfo[[1]][2]

	conditions <- c("0m", "1m", "2m", "4m")
	headFiles <- list.files(pattern = "^HeadData")
    respFiles <- list.files(pattern = "\\.xlsx")

	respData <- NULL
	catchData <- NULL
	accuData <- NULL

	for (f in respFiles[c(1:4)]){
		thisData <- NULL
		thisAccu <- NULL
		fileInfo <- strsplit(f, '_')
		scene <- fileInfo[[1]][2]

		for (i in 1:4){
			tempData <- read.xlsx(f, i)
			tempData$Scene <- scene
			tempData$Distance <- conditions[i]
			tempData$Stimulis_abs <- abs(tempData$Stimulis)
			thisData <- rbind(thisData, tempData)

			tempAccu <- data.frame(unique(tempData$Stimulis_abs))
			names(tempAccu) <- "Intensity"

			for (j in 1:length(tempAccu$Intensity)){
			  resps <- tempData$Response[tempData$Stimulis_abs == tempAccu$Intensity[j]]

			  if (j == 1) {
			    accus <- sum(resps) / length(resps)
			  } else {
			    accus <- rbind(accus, sum(resps) / length(resps))}
			}

			tempAccu$respProb <- accus
			tempAccu$Scene <- scene
			tempAccu$Distance <- conditions[i]
			thisAccu <- rbind(thisAccu, tempAccu)
		}

			respData <- rbind(respData, thisData)
			accuData <- rbind(accuData, thisAccu)

			tempData <- read.xlsx(f, 5)
			tempData$Scene <- scene
			tempData$Stimulis_abs <- abs(tempData$Stimulis)
			catchData <- rbind(catchData, tempData)
	}

	catchAccuracy <- sum(catchData$Response)/length(catchData$Response)
	percent(catchAccuracy)

	if (catchAccuracy < 0.96) {
		SbjWithLowCatchUpAccu <- cbind(SbjWithLowCatchUpAccu, sbjNo)
	}

	headData <- NULL
	for (f in headFiles[c(1:4)]){
	  thisData <- NULL
	  fileInfo <- strsplit(f, '_')
	  scene <- fileInfo[[1]][2]
	  for (i in 1:4){
	    tempData <- read.csv(f)
	    headData <- rbind(headData, tempData)
	  }
	}
	headData$Stimuli_abs <- abs(headData$Stimuli)

	# Get rid of those zero points after the movement disappears
	rmidx <- NULL
	for (i in 2:nrow(headData)){
	  if (headData$Head_z[i] == 0){
	    if (headData$TrialNo[i-1] == headData$TrialNo[i]){
	      rmidx <- c(rmidx, i)
	    }
	  }
	}
	headData <- headData[-rmidx, ]

	# Get rid of the catch trials
	simpleIdx <- which(headData$Condition == "Simple")
	headData <- headData[-simpleIdx, ]

	# Change the conditions to distances
	headData$Distance[headData$Condition == "Very Close"] <- "0m"
	headData$Distance[headData$Condition == "Close"] <- "1m"
	headData$Distance[headData$Condition == "Middle"] <- "2m"
	headData$Distance[headData$Condition == "Far"] <- "4m"

	save(respData, accuData, catchAccuracy, headData, file = "EarlyData.RData")

	sepLRData <- NULL

	respData <- respData[-which(respData$Stimulis_abs == 0), ]
	respData$mDirection <- "Right"
	respData$mDirection[respData$Stimulis < 0 ] <- "Left"

	rightResp <- NULL
	for (i in 1:nrow(respData)){
		if ((respData$mDirection[i] == "Right" & respData$Response[i] == 1) | (respData$mDirection[i] == "Left" & respData$Response[i] == 0)) {
		  rightResp[i] <- 1
		} else {
		  rightResp[i] <- 0
		}
	}
	respData$Right <- rightResp
	respData$Left <- 1 - respData$Right

	for (s in scenes) {
	    for (d in distances) {
	      thisData <- subset(respData, Scene == s & Distance == d)
	      lrData <- sepLR(thisData)
	      lrData$Scene <- s
	      lrData$Distance <- d
	      
	      sepLRData <- rbind(sepLRData, lrData)
	    }
    }

    save(sepLRData, file = "DataToFit.RData")

    setwd("..")

}

if (length(SbjWithLowCatchUpAccu) > 0){
	print(SbjWithLowCatchUpAccu)
	save(SbjWithLowCatchUpAccu, file = "ExcludeCatchUpList.RData")
}

rm(list = ls())



