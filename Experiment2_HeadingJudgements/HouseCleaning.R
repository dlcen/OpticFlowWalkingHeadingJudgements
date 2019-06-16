library(plyr); library(data.table); library(scales)

load("AllThresholds.RData")

Scenes <- as.character(unique(allThreshs$Scene))
Dists <- as.character(unique(allThreshs$Distance))

allThreshs_clean <- data.table(allThreshs)

for (s in Scenes) {
        for (d in Dists) {
                thisThreshs <- subset(allThreshs_clean, Scene == s & Distance == d)
                mean.thresh <- mean(thisThreshs$thresh, na.rm = T)
                std <- sd(thisThreshs$thresh, na.rm = T)
                outlier.idx <- which(thisThreshs$thresh > mean.thresh + 3 * std | thisThreshs$thresh < mean.thresh - 3 * std)
                if (length(outlier.idx) > 0) {
                        outlier.no <- as.character(thisThreshs$SubjectNo[outlier.idx])
                        if (length(outlier.no) > 0) {print(c(outlier.no, s, d))}
                        allThreshs_clean[SubjectNo == outlier.no & Scene == s & Distance == d]$thresh <- NA
                }
        }
}

if (file.exists("ExcludeCatchUpList.RData")){
        load(file = "ExcludeCatchUpList.RData")
        allThreshs_clean <- allThreshs_clean[! SubjectNo %in% SbjWithLowCatchUpAccu]
}

save(allThreshs_clean, file = "AllThresholdsCleaned.RData")

percent(sum(length(which(is.na(allThreshs_clean$thresh))))/length(allThreshs$thresh))

rm(list = ls())