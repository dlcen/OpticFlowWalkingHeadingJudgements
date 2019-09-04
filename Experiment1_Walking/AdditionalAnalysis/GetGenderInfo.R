library(data.table); library(plyr)

info.file <- "Data/SbjInfo.csv"
sbj.info <- read.csv(info.file)
sbj.info <- data.table(sbj.info)

sbj.nos  <- as.character(unique(sbj.info$Subject.No))

load("Data/meanErr.RData")
load("Data/segData.RData")

trial.meanErr.4m <- data.table(trial.meanErr.4m)
segData_aligned  <- data.table(segData_aligned)

trial.meanErr.4m$Gender <- " "
segData_aligned$Gender  <- " "

for (this.sbj in sbj.nos){
  trial.meanErr.4m[SubjectNo == this.sbj]$Gender <- sbj.info[Subject.No == this.sbj]$Gender
  segData_aligned[SubjectNo == this.sbj]$Gender  <- sbj.info[Subject.No == this.sbj]$Gender
}

save(trial.meanErr.4m, segData_aligned, file = "Data/GenderAnalysis.RData")