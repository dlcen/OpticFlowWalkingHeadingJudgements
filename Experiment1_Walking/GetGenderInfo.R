library(data.table); library(plyr)

info.file <- "SbjInfo.csv"

sbj.info <- read.csv(info.file)

sbj.info <- data.table(sbj.info)