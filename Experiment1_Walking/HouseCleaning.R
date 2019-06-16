library(plyr); library(reshape); library(data.table); library(ggplot2)

outlierSummary<-function(variable, TrialNo, SubjNo, digits = 2){

        zvariable<-(variable-mean(variable, na.rm = TRUE))/sd(variable, na.rm = TRUE)
        tobeExcluded <- which(abs(zvariable) >= 3)
        ncases<-length(na.omit(zvariable))

        outlierNo <- SubjNo[tobeExcluded]
        cat("Absolute z-score greater than 3 ", TrialNo, ": ", outlierNo , "\n")
        return(outlierNo)
}

# Read the data
dat <- read.csv("Data/Data_raw_all.csv", check.names = F)
dat <- data.table(dat)
Dat_raw <- dat

# Drop the data before 6.5m from the target and after 1m from the target
distrange <- which(dat$z > 0.5 & dat$z < 6)
dat <- dat[distrange]

Dat_clean <- dat
Dat_raw_clean <- Dat_raw

# Align the beginning of the data
source("align.R")

alignedDat_raw <- ddply(Dat_raw_clean, c("SubjectNo", "SceneOrder", "Scene", "Direction", "DirectionOrder", "Block", "TotalTrialNo", "TrialNo"), plyr::mutate, x = align(headingErr, x, z), z = z - z[1])
alignedDat_raw <- data.table(alignedDat_raw)

distrange <- which(alignedDat_raw$z > 0.5 & alignedDat_raw$z < 6)
alignedDat <- alignedDat_raw[distrange]

# Segment the data
segCal <- function(rawData, nBin = 100, distrange = c(0.5, 6), datatype = 1) {
      itv <- (distrange[2] - distrange[1])/nBin
      z_seg <- seq(distrange[1], distrange[2], itv)
      
      rawData$segNo <- 0
      rawData$seg.z <- 0
      for (i in 2:length(z_seg)) {
            period <- which(rawData$z > z_seg[i - 1] & rawData$z <= z_seg[i])
            rawData$segNo[period] <- i -1
            rawData$seg.z[period] <- z_seg[i]
      }
      
      segData <- ddply(rawData, c("SubjectNo", "SceneOrder", "Scene", "Direction", "DirectionOrder", "Block", "TotalTrialNo", "TrialNo", "seg.z", "segNo"), plyr::summarize, x = mean(x, na.rm = TRUE), headingErr = mean(headingErr, na.rm = TRUE), headYawTg = mean(headYawTg, na.rm = T), bodyYawTg = mean(bodyYawTg, na.rm = T))
      return(segData)
}


# Remove those target-heading angles <-10 degrees and >20 degrees 
## First check the means
### Calculate the mean target-heading angle for each trial
trial.meanErr.long <- ddply(Dat_clean, c("SubjectNo", "Block", "TotalTrialNo", "TrialNo", "SceneOrder", "Scene", "Direction", "DirectionOrder"), plyr::summarise, meanErr = mean(headingErr, na.rm = T))
trial.meanErr.melt <- melt(trial.meanErr.long, c("SubjectNo", "Block", "TotalTrialNo", "TrialNo", "SceneOrder", "Scene", "Direction", "DirectionOrder"))
trial.meanErr.wide <- cast(trial.meanErr.melt, SubjectNo + SceneOrder + DirectionOrder  ~ TotalTrialNo)
with(trial.meanErr.wide, table(SceneOrder, DirectionOrder))

# Find out those with mean target-heading angle larger than 20 or smaller than -10
weirdo <- which(trial.meanErr.long$meanErr > 20 | trial.meanErr.long$meanErr < -10)

## Get the subject no and trial no. for these weirdos
weirdoNo <- as.character(trial.meanErr.long$SubjectNo[weirdo])
weirdoTrial <- as.numeric( trial.meanErr.long$TotalTrialNo[weirdo])

## Make these weirdo NA
if (length(weirdo) > 0 ) {
      for (i in 1:length(weirdoNo)) {
            Dat_clean[SubjectNo == weirdoNo[i] & TotalTrialNo == weirdoTrial[i]]$headingErr <- NA
            Dat_raw_clean[SubjectNo == weirdoNo[i] & TotalTrialNo == weirdoTrial[i]]$headingErr <- NA
            alignedDat_raw[SubjectNo == weirdoNo[i] & TrialNo == weirdoTrial[i]]$headingErr <- NA
      }
}


# Check whether there are any data points still larger than 20° or smaller than -10°
weirdo <- which(Dat_clean$headingErr < -10 | Dat_clean$headingErr > 20)
Dat_clean[weirdo]$headingErr <- NA

weirdo <- which(Dat_raw_clean$headingErr < -10 | Dat_raw_clean$headingErr > 20)
Dat_raw_clean[weirdo]$headingErr <- NA

weirdo <- which(alignedDat_raw$headingErr < -10 | alignedDat_raw$headingErr > 20)
alignedDat_raw[weirdo]$headingErr <- NA

# Check how many data points were deleted
trial.summary <- ddply(Dat_clean, c("SubjectNo", "SceneOrder", "Scene", "Direction", "TotalTrialNo", "TrialNo"), plyr::summarise, na.no = sum(is.na(headingErr)), total.no = length(headingErr))
trial.summary$ratio <- trial.summary$na.no / trial.summary$total.no
na.trial <- which(trial.summary$ratio > 1/2) # 5 trials out of 1835

# Get those trials with more than 1/2 points that were cut off
for ( i in na.trial){
        thisSubject <- as.character(trial.summary$SubjectNo[i])
        thisTrial <- as.numeric(trial.summary$TotalTrialNo[i])
        cat(thisSubject, "  ", thisTrial, "\n")
        Dat_clean[SubjectNo == thisSubject & TotalTrialNo == thisTrial]$headingErr <- NA
        Dat_raw_clean[SubjectNo == thisSubject & TotalTrialNo == thisTrial]$headingErr <- NA
        alignedDat_raw[SubjectNo == thisSubject & TrialNo == thisTrial]$headingErr <- NA
}

# find out those with mean target-heading angle larger than 3SDs from the mean in each condition
## Need to recalculate the mean of each trial
trial.meanErr.long <- ddply(Dat_clean, c("SubjectNo", "Block", "TotalTrialNo", "TrialNo", "SceneOrder", "Scene", "Direction", "DirectionOrder"), plyr::summarise, meanErr = mean(headingErr, na.rm = T))

## Get the conditions ready
scenes <- as.character(unique(trial.meanErr.long$Scene))
scenes <- scenes[-1]

## Iterate through each condition
nSubjects <- as.character(trial.meanErr.wide$SubjectNo)
trial.meanErr.long <- data.table(trial.meanErr.long)
outliers <- NULL; TrialNo <- NULL
for (s in scenes) {
      for (i in 1:4) {
            thisTrial <- trial.meanErr.long[Scene == s & TrialNo == i ]
            cat(s, ', Trial ', i, "\n")
            idx <- outlierSummary(thisTrial$meanErr, i, nSubjects)
            if (length(idx) > 0 ) {
                    outliers <- c(outliers, idx)
                    TrialNo <- c(TrialNo, thisTrial$TotalTrialNo[thisTrial$SubjectNo %in% idx])
            }
      }
}

too.many.missing <- NULL
if (length(TrialNo) > 0) {
      for ( i in 1:length(TrialNo)){
              thisSubject <- outliers[i]
              thisTrial <- TrialNo[i]
              if (thisTrial > 4) {
                      idx <- which(trial.meanErr.long$SubjectNo == thisSubject & trial.meanErr.long$TotalTrialNo == thisTrial)
                      trial.meanErr.long$meanErr[idx] <- NA
              }
              if ( i >= 2 ) {
                if (thisSubject == outliers[i - 1] & thisTrial == TrialNo[i - 1] + 1) {
                  too.many.missing <- c(too.many.missing, thisSubject)
                }
              }
      }
}

# Find out whether there is any missing trials
nTrials <- c(1:36)
missingTrials <- NULL
trial.meanErr.long <- data.table(trial.meanErr.long)
excl.sbj.missing <- NULL
for (sbj in nSubjects){
        thisSbj <- trial.meanErr.long[SubjectNo == sbj]
        thisTrials <- as.numeric(thisSbj$TotalTrialNo)
        missing <- nTrials[!nTrials %in% thisTrials]
        hitTrials <- missing[missing %in% c(5, 8, 9, 12, 13, 16, 17, 20, 21, 24, 25, 28, 29, 32, 33)]
        if (length(hitTrials) > 0) {
                excl.sbj.missing <- c(sbj)
        }
}

# Check whether the missing and nan trials are belong to the critical trials
na.trials <- which(is.na(trial.meanErr.long$meanErr))
excl.trials <- trial.meanErr.long$TotalTrialNo[na.trials]
excl.idx <- which(excl.trials %in% c(5, 9, 13, 17, 21, 25, 29, 33))
excl.sbj.idx <- na.trials[excl.idx]
excl.sbj <- as.character(unique(trial.meanErr.long$SubjectNo[excl.sbj.idx]))
excl.sbj <- c(excl.sbj, excl.sbj.missing, too.many.missing)


if (length(excl.sbj) > 0 ) {
      excl.sbj.idx <- which(trial.meanErr.long$SubjectNo %in% excl.sbj)
      trial.meanErr.long <- trial.meanErr.long[-excl.sbj.idx, ]
      Dat_clean <- Dat_clean[-which(Dat_clean$SubjectNo %in% excl.sbj), ]
      Dat_raw_clean <- Dat_raw_clean[-which(Dat_raw_clean$SubjectNo %in% excl.sbj), ]
      alignedDat_raw        <- alignedDat_raw[-which(alignedDat_raw$SubjectNo %in% excl.sbj), ]
}

trial.meanErr.melt <- melt(trial.meanErr.long, c("SubjectNo", "Block", "TotalTrialNo", "TrialNo", "SceneOrder", "Scene", "Direction", "DirectionOrder"))
trial.meanErr.wide <- cast(trial.meanErr.melt, SubjectNo + SceneOrder + DirectionOrder  ~ TotalTrialNo)
with(trial.meanErr.wide, table(SceneOrder, DirectionOrder))

trial.meanErr.4m <- ddply(Dat_clean[Dat_clean$z >= 1 & Dat_clean$z <=5], c("SubjectNo", "Block", "TotalTrialNo", "TrialNo", "SceneOrder", "Scene", "Direction", "DirectionOrder"), plyr::summarise, meanErr = mean(headingErr, na.rm = T))

segData_clean <- segCal(Dat_clean)

segData_raw_clean <- segCal(Dat_raw_clean,  nBin = 125, distrange = c(0, 6.25))

distrange <- which(alignedDat_raw$z > 0.5 & alignedDat_raw$z < 6)
alignedDat <- alignedDat_raw[distrange]

segData.aligned.all <- segCal(alignedDat_raw,  nBin = 125, distrange = c(0, 6.25))

segData_aligned <- segCal(alignedDat)


# Calculate the early and later part on the trial data
endDat <- NULL

## Early part
early_range_from_target <- c(5.75, 6.25)
subDat <- Dat_clean[z <= (7 - early_range_from_target[1]) & z >= (7 - early_range_from_target[2])]
subMean <- subDat[, .(headingErr = mean(headingErr, na.rm = T), headYawTg = mean(headYawTg, na.rm = T), bodyYawTg = mean(bodyYawTg, na.rm = T)), by = .(SubjectNo, Scene, SceneOrder, Direction, Block, TrialNo)]
subMean$end <- "early"
endDat <- rbind(endDat, subMean)

## Later part
later_range_from_target <- c(1.75, 2.25)
subDat <- Dat_clean[z <= (7 - later_range_from_target[1]) & z >= (7 - later_range_from_target[2])]
subMean <- subDat[, .(headingErr = mean(headingErr, na.rm = T), headYawTg = mean(headYawTg, na.rm = T), bodyYawTg = mean(bodyYawTg, na.rm = T)), by = .(SubjectNo, Scene, SceneOrder, Direction, Block, TrialNo)]
subMean$end <- "late"
endDat <- rbind(endDat, subMean)

save(Dat_clean, Dat_raw_clean, alignedDat_raw, file = "Data/Data_clean.RData")
save(trial.meanErr.long, trial.meanErr.4m, trial.meanErr.wide, file = "Data/meanErr.RData")
save(segData_clean, segData_raw_clean, segData.aligned.all, segData_aligned, file = "Data/segData.RData")
save(endDat, file = "Data/endData.RData")

rm(list = ls())