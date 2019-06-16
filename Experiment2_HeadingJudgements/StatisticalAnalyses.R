# Running statistical analyses on the heading judgement thresholds

library(car); library(ggplot2); library(pastecs); library(psych); library(compute.es);  library(multcomp); library(reshape); library(Hmisc); library(plyr); library(boot)
library(ez); library(nlme); library(data.table); library(gsubfn); library(gtools)

# Load the data (should be in the Data folder)
load(file = "AllThresholdsCleaned.RData") 

threshs <- data.table(allThreshs_clean)
threshs$Scene <- factor(threshs$Scene)
threshs$Scene <- factor(threshs$Scene, levels = levels(threshs$Scene), labels = c('Cloud', 'Room', 'Line', 'Outline'))

threshs.scene <- threshs[, .(thresh = mean(thresh, na.rm = T)), by = .(SubjectNo, Scene)]
threshs.scene$Scene <- factor(threshs.scene$Scene, levels = levels(threshs.scene$Scene), labels = c('Cloud', 'Room', 'Line', 'Outline'))


# Descriptive stats
ciCal <- function(level = 0.975, data) {
        m <- mean(data, na.rm = T)
        s <- sd(data, na.rm = T)
        n <- length(data)
        ci <- qt(level, df = n-1) * s/sqrt(n)
}

threshs.scene[, .(Mean = mean(thresh, na.rm = T), CI = ciCal(0.975, thresh)), by = .( Scene)]

## Mean over the distances
by(threshs.scene$thresh, threshs.scene$Scene, stat.desc, basic = FALSE)

## At each distance
by(threshs$thresh, interaction(threshs$Scene, threshs$Distance), stat.desc, basic = FALSE)

## Differences between scenes (on mean thresholds collapsed over distances)
sceneM <- ezANOVA(data = threshs.scene, dv = .(thresh), wid = .(SubjectNo), within = .(Scene))
sceneM

Dfn <- sceneM$ANOVA["DFn"]
Dfd <- sceneM$ANOVA["DFd"]
GGe <- sceneM$`Sphericity Corrections`["GGe"]

print(paste0("DF of parameters: ", Dfn * GGe))
print(paste0("DF of model: ", Dfd * GGe))

pairwise.t.test(threshs.scene$thresh, threshs.scene$Scene, p.adjust.method = "bonferroni", paired = T)
pairwise.t.test(threshs.scene$thresh, threshs.scene$Scene, p.adjust.method = "none", paired = T)

# Examine the difference in the change of heading judgement over distance between the scenes
## Building models
threshs$distance <- as.numeric(gsub("\\D", "", threshs$Distance))

baseline <- lme(thresh ~ 1, random = ~1|SubjectNo, data = threshs, method = "ML", na.action = na.exclude, control = list(opt="optim"))

distM0  <- update(baseline, .~. + distance)
distMI  <- update(distM0, random = ~1|SubjectNo/Scene)
distMS  <- update(distMI, random = ~ distance|SubjectNo/Scene)
# distMAR <- update(distMS, correlation = corAR1())
# distMH  <- update(distMAR, weights = varExp(form = ~ distance))

sceneModel <- update(distMS, .~. + Scene)
finalModel <- update(sceneModel, .~. + Scene : distance)

## Compare models
anova(baseline, distM0, distMI, distMS, sceneModel, finalModel)

printCoefmat(summary(finalModel)$tTable)

## *Post hoc*
### Examine the slope in each scene using one-sample tests
contrast.matrix <- rbind(
        "Slope: Cloud"         = c(0, 1, 0, 0, 0, 0, 0, 0),
        "Slope: Room"          = c(0, 1, 0, 0, 0, 1, 0, 0),
        "Slope: Line"          = c(0, 1, 0, 0, 0, 0, 1, 0),
        "Slope: Outline"       = c(0, 1, 0, 0, 0, 0, 0, 1)
)
comps <- glht(finalModel, contrast.matrix)
summary(comps, test = adjusted("none"))

### Comparing the slopes
contrast.matrix <- rbind(
        "Slope: Room - Cloud"      = c(0, 0, 0, 0, 0, 1, 0, 0),
        "Slope: Line - Cloud"      = c(0, 1, 0, 0, 0, 0, 1, 0),
        "Slope: Outline - Cloud"   = c(0, 1, 0, 0, 0, 0, 0, 1),
        "Slope: Line - Room"       = c(0, 1, 0, 0, 0, -1, 1, 0),
        "Slope: Outline - Room"    = c(0, 1, 0, 0, 0, -1, 0, 1),
        "Slope: Outline - Line"    = c(0, 1, 0, 0, 0, 0, -1, 1)
)
comps <- glht(finalModel, contrast.matrix)
summary(comps, test = adjusted("bonferroni"))


# Compare the two groups (Experienced vs. New)

new.sbj.No <- c(paste("S", c(3:9), sep = "0"), paste0("S", 10:13), "S26")
old.sbj.No <- c(paste0("S", 15:30)); old.sbj.No <- old.sbj.No[-c(2, 4, 12, 13)]

threshs$Group <- 1
threshs[SubjectNo %in% new.sbj.No]$Group <- 2
threshs$Group <- factor(threshs$Group, levels = c(1:2), labels = c("Experienced", "New"))

threshs.scene$Group <- 1
threshs.scene[SubjectNo %in% new.sbj.No]$Group <- 2
threshs.scene$Group <- factor(threshs.scene$Group, levels = c(1:2), labels = c("Experienced", "New"))

threshs.mean <- threshs.scene[, .(thresh = mean(thresh, na.rm = T)), by = c("SubjectNo", "Group")]

## Compare the mean thresholds
threshs.mean[, .(Mean = mean(thresh, na.rm = T), SD = sd(thresh, na.rm = T)), by = c("Group")]

t.test(thresh ~ Group, threshs.mean, var.equal = T)

## Using mixed ANOVA
two.grps.model <- ezANOVA(data = threshs.scene, dv = .(thresh), wid = .(SubjectNo), within = .(Scene), between = .(Group), type = 3)
two.grps.model

## Using growth modelling
baseline <- lme(thresh ~ 1, random = ~ 1|SubjectNo/Scene, data = threshs, method = "ML", na.action = na.exclude)

distMI   <- update(baseline, .~. + distance)
distMS   <- update(distMI, random = ~ distance|SubjectNo/Scene, control = list(opt = "optim"))

sceneMI  <- update(distMS,  .~. + Scene)
sceneMS  <- update(sceneMI, .~. + Scene : distance)

grpMI    <- update(sceneMS, .~. + Group)
grpMS    <- update(grpMI,   .~. + Group : distance)

grpScnI  <- update(grpMS,   .~. + Group : Scene)
grpScnS  <- update(grpScnI, .~. + Group : Scene : distance)

anova(baseline, distMI, distMS, sceneMI, sceneMS, grpMI, grpMS, grpScnI, grpScnS)

save(threshs, file = "AllThresholdsCleanedGrouped.RData")
