getThreshold <- function(Intensity, pred, lower.prob = 0.25, upper.prob = 0.75) {
        lower <- abs(pred - lower.prob)
        upper <- abs(pred - upper.prob)
        lower.idx <- which(lower == min(lower))
        upper.idx <- which(upper == min(upper))
        lower.value <- Intensity[lower.idx]
        upper.value <- Intensity[upper.idx]
        threshold <- upper.value - lower.value
        return(threshold)
}