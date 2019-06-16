library(compute.es); library(ez); library(ggplot2); library(multcomp); library(nlme); library(pastecs); library(reshape); library(plyr); library(car); library(data.table); 

# Compare the difference in mean target-heading angle between the conditions, using Repeated-measures ANOVA
load(file = "Data/meanErr.RData")

trial.meanErr.4m 	      <- data.table(trial.meanErr.4m)
offset.err.trial1         <- trial.meanErr.4m[Block %in% c(2, 4, 6, 8) & TrialNo == 1, ]
offset.err.trial1$Scene   <- droplevels(offset.err.trial1$Scene)
offset.err.trial1$Scene   <- factor(offset.err.trial1$Scene, levels = levels(offset.err.trial1$Scene)[c(2, 3, 1, 4)], labels = c("Line", "Outline", "DotCloud", "Room"))

desc.scene <- offset.err.trial1[, .(Mean = mean(meanErr, na.rm = T), SD = sd(meanErr, na.rm = T)), by = c("Scene")]
by(offset.err.trial1$meanErr, offset.err.trial1$Scene, stat.desc, basic = FALSE)

## Check whether all of them are significantly smaller than 10°
onesample_tests <- by(offset.err.trial1$meanErr, offset.err.trial1$Scene, function(x) t.test(x, mu = 10, alternative = "less"))
onesample_tests

## check assumptions
leveneTest(offset.err.trial1$meanErr, offset.err.trial1$Scene)

## Using ezANOVA 
sceneModel <- ezANOVA(data = offset.err.trial1, dv = .(meanErr), wid = .(SubjectNo),  within = .(Scene), type = 3, detailed = TRUE)
sceneModel


### Post hoc
prt.bonf <- pairwise.t.test(offset.err.trial1$meanErr, offset.err.trial1$Scene, paired = TRUE, p.adjust.method = "bonferroni")
prt.bonf

#### To get the t value between Cloud and Outline
t.test(meanErr ~ Scene, data = offset.err.trial1[Scene %in% c("DotCloud", "Outline")], paired = TRUE, var.equal = TRUE)

# Mean target-heading angles of Trial 1 as a function of distance 
load(file = 'Data/segData.RData')

segData_clean <- data.table(segData_clean)
offset_seg_trial1 <- segData_clean[Block %in% c(2, 4, 6, 8) & TrialNo == 1 & seg.z >= 1 & seg.z <= 5]
offset_seg_trial1$Scene <- droplevels(offset_seg_trial1$Scene)

## Centralise the distance
offset_seg_trial1[, distance  := seg.z - 1.05]

## Building models
m.basic   <- lme(headingErr ~ 1, random = ~ 1|SubjectNo/Scene, data = offset_seg_trial1, method = "ML", na.action = na.exclude, control = list(opt="optim"))

m.dist.i  <- update(m.basic,     .~. + distance)
m.dist.s  <- update(m.dist.i,    random = ~ distance | SubjectNo/Scene)

m.scene.i <- update(m.dist.s,    .~. + Scene)
m.scene.s <- update(m.scene.i,   .~. + Scene:distance)

### Compare the models
anova(m.basic, m.dist.i, m.dist.s, m.scene.i, m.scene.s)

### Show the full model
summary(m.scene.s, corr = FALSE)

### *Post hoc* tests
#### Check the slopes
contrast.matrix <- rbind(
  "Cloud"         = c(0, 1, 0, 0, 0, 0, 0, 0),
  "Line"          = c(0, 1, 0, 0, 0, 1, 0, 0),
  "Outline "      = c(0, 1, 0, 0, 0, 0, 1, 0),
  "Room "         = c(0, 1, 0, 0, 0, 0, 0, 1)
)
postHocs <-glht(m.scene.s, contrast.matrix) 
summary(postHocs, test = adjusted("none"))
summary(postHocs, test = adjusted("bonferroni"))

#### Compare the slopes
contrast.matrix <- rbind(
  "Line - Cloud"          = c(0, 0, 0, 0, 0, 1, 0, 0),
  "Outline - Cloud "      = c(0, 0, 0, 0, 0, 0, 1, 0),
  "Room - Cloud "         = c(0, 0, 0, 0, 0, 0, 0, 1),
  "Outline - line"        = c(0, 0, 0, 0, 0, -1, 1, 0),
  "Room - line"           = c(0, 0, 0, 0, 0, -1, 0, 1),
  "Room - Outline"        = c(0, 0, 0, 0, 0, 0, -1, 1) 
)
postHocs <-glht(m.scene.s, contrast.matrix)
summary(postHocs, test = adjusted("none"))
summary(postHocs, test = adjusted("bonferroni"))

# Examine the *early* and *late* parts of the dataset as a function of trial
load(file = "Data/endData.RData")

endDat <- data.table(endDat)

offset.early 			<- endDat[ Block %in% c(2, 4, 6, 8) & end == "early", ]
offset.early$Scene 		<- droplevels(offset.early$Scene)
offset.early$Trial_ct   <- offset.early$TrialNo - 1
offset.early$TrialNo    <- factor(offset.early$TrialNo, levels = c(1:4), labels = paste0("Trial", c(1:4)))

after.early 			<- endDat[ Block %in% c(3, 5, 7, 9) & end == "early", ]
after.early$Scene 		<- droplevels(after.early$Scene)
after.early$TrialNo     <- factor(after.early$TrialNo, levels = c(1:4), labels = paste0("Trial", c(1:4)))


## Reduction of heading-target angle in the test trials
offset.early.melt <- melt(offset.early, id = c("SubjectNo", "Scene", "TrialNo"), measure.vars = "headingErr")
offset.early.wide <- cast(offset.early.melt, SubjectNo + Scene ~ TrialNo)
offset.early.wide <- data.table(offset.early.wide)
offset.early.wide[, .(MeanReduction = mean((Trial4 - Trial1), na.rm = T), SD = sd((Trial4 - Trial1), na.rm = T)), by = c("Scene")]


## After-effects in the non-offet trials following the test trials (Note the resultant p values should be Bonferroni-corrected by multupling 4)
by(after.early[TrialNo == "Trial1"]$headingErr, after.early[TrialNo == "Trial1"]$Scene, function(x) t.test(x, mu = 0, alternative = "less")) # Note this is one-tailed


## Examine the difference between *early* and *late* in Trial2 - Trial4
offset.ends			<- endDat[ Block %in% c(2, 4, 6, 8) & TrialNo %in% c(2:4), ]
offset.ends$trialNo <- offset.ends$TrialNo
offset.ends$TrialNo <- factor(offset.ends$TrialNo, levels =  c(1:4), labels = paste0("Trial", c(1:4)))

### Descriptive statistics
offset.end.melt <- melt(offset.ends, id.vars = c("SubjectNo", "Scene", "TrialNo", "end"), measure.vars = "headingErr")
offset.end.wide <- cast(offset.end.melt, SubjectNo + Scene + TrialNo ~ end)
offset.end.wide <- data.table(offset.end.wide)

offset.end.mean <- offset.end.wide[, .(Late = mean(late, na.rm = T), Early = mean(early, na.rm = T)), by = c("SubjectNo", "Scene")] 
offset.end.mean[, .(mean_difference = mean((Late - Early), na.rm = T), SD = sd((Late - Early), na.rm = T)), by = c("Scene")]

## Linear model - only for trial 2 - 4 to see whether the pattern of Trial 1 repeated
baseline 	  <- lme(headingErr ~ 1, random = ~1|SubjectNo/Scene/end, data = offset.ends, method = "ML", na.action = na.exclude, control = list(opt = "optim"))

TrialRI 	  <- update(baseline, .~. + trialNo)
TrialRS 	  <- update(TrialRI,  random = ~ trialNo|SubjectNo/Scene/end)
TrialAR  	  <- update(TrialRS, correlation = corAR1())

EndRI         <- update(TrialAR,  .~. + end)
EndRS         <- update(EndRI,    .~. + end : trialNo)

sceneRI       <- update(EndRS,    .~. + Scene)
sceneRS       <- update(sceneRI,  .~. + Scene : trialNo)

SceneEndI     <- update(sceneRS,  .~. + Scene : end)
SceneEndS     <- update(SceneEndI,.~. + Scene : end : trialNo)

anova(baseline, TrialRI, TrialRS, TrialAR, EndRI, EndRS, sceneRI, sceneRS, SceneEndI, SceneEndS)
