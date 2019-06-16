
load(file = "DataToFit.RData")

# names(sepLRData) <- c("Pc", "nTrials", "nRight", "nLeft", "Intensity", "Scene", "Distance")
sepLRData                               <- data.table(sepLRData)
sepLRData$Direction                     <- "Right" 
sepLRData[Intensity < 0]$Direction      <- "Left"
sepLRData$Pc                            <- sepLRData$nRight / (sepLRData$nLeft + sepLRData$nRight)


# If no warnings use *glm*, otherwise use *brglm*
Scenes <- as.character(unique(sepLRData$Scene))
Dists <- as.character(unique(sepLRData$Distance))

predData <- NULL
for (s in Scenes) {
        for (d in Dists) {
                thisData <- subset(sepLRData, Scene == s & Distance == d)
                anyProblem <- tryCatch(glm(cbind(nRight, nLeft) ~ Intensity, binomial, thisData), warning = function(w) w)
                if (is(anyProblem, "warning")) {
                        glm.model <- brglm(cbind(nRight, nLeft) ~ Intensity, binomial, thisData)
                } else {
                        glm.model <- glm(cbind(nRight, nLeft) ~ Intensity, binomial, thisData)
                }
                this.nd <- expand.grid(Intensity = seq(-5, 5, len=10000))
                this.pred <- predict(glm.model, newdata = this.nd, type = "response")
                this.nd$pred <- this.pred
                this.nd$Scene <- s
                this.nd$Distance <- d
                predData <- rbind(predData, this.nd)
        }
}

thresholds <- ddply(predData, c("Scene", "Distance"), plyr::summarise, thresh = getThreshold(Intensity, pred))
