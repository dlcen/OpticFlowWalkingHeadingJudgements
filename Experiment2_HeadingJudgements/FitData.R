library(MPDiR); library(data.table); library(plyr); library(brglm)

# Note: the current directory should be in the "Data" folder

subjectFolders <- list.files(pattern = '^S')

source("../getThreshold.R")

allThreshs <- NULL
for (thisSbj in subjectFolders) {
        setwd(thisSbj)

        sbjInfo <- strsplit(thisSbj, split = "_")
        sbjNo <- sbjInfo[[1]][1]
        sbjOrder <- sbjInfo[[1]][2]
        source("../../fitting.R")
        thresholds$SubjectNo <- sbjNo
        thresholds$SceneNo <- sbjOrder
        save(thresholds, file = "Thresholds.RData")

        allThreshs <- rbind(allThreshs, thresholds)
        setwd("..")
        rm(list = c("predData", "sepLRData", "this.nd", "thisData", "thresholds", "anyProblem", "d", "s", "this.pred", "sbjInfo", "sbjOrder"))
}

save(allThreshs, file = "AllThresholds.RData")
rm(list = ls())