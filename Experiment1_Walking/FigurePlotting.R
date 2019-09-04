library(ggplot2); library(reshape); library(data.table); library(cowplot); library(plyr); library(showtext); library(extrafont);


source("egolineCal.R")
egoline <- egolineCal(prismDeg = 10, distance = 7)

fontfile <- paste("D:/OneDirve_CU/OneDrive - Cardiff University/Papers/Paper 1 VR/Data Analysis/Heading Judgment/Stats/", "Helvetica", "Helvetica.ttf", sep = .Platform$file.sep)
font_add("Helvetica", regular = fontfile)

showtext_auto()


median_cl_boot <- function(x, conf = 0.95) {
        lconf <- (1 - conf)/2
        uconf <- 1 - lconf
        require(boot)
        bmedian <- function(x, ind) median(x[ind])
        bt <- boot(x, bmedian, 1000)
        bb <- boot.ci(bt, type = "perc")
        data.frame(y = median(x), ymin = quantile(bt$t, lconf), ymax = quantile(bt$t, uconf))
}

# Plot path
## Load data
segData         <- read.table("Data/segData_clean.csv", check.names = F, header = T)
segData         <- data.table(segData)

segData.aligned         <- read.table("Data/segData_aligned.csv", header = T)
segData.aligned         <- data.table(segData.aligned)

### Offset trials
offset.segData          <- segData[segData$Block %in% c(2, 4, 6, 8), ]
offset.segData$Scene    <- droplevels( offset.segData$Scene)
offset.segData$Scene    <- factor(offset.segData$Scene, levels(offset.segData$Scene)[c(2, 4, 1, 3)], labels = c(sprintf("%-20s", "Line"), sprintf("%-20s", "Room"), sprintf("%-20s", "Cloud"), sprintf("%-20s", "Outline")))

offset.segData.aligned  <- segData.aligned[segData.aligned$Block %in% c(2, 4, 6, 8), ]
offset.segData.aligned$Scene    <- droplevels( offset.segData.aligned$Scene)
offset.segData.aligned$Scene    <- factor(offset.segData.aligned$Scene, levels(offset.segData.aligned$Scene)[c(2, 4, 1, 3)], labels = c(sprintf("%-20s", "Line"), sprintf("%-20s", "Room"), sprintf("%-20s", "Cloud"), sprintf("%-20s", "Outline")))

### Offset means
offset.segMean          <- ddply(offset.segData, c("SubjectNo", "Scene", "Direction", "Block", "seg.z"), plyr::summarise, x = mean(x, na.rm = T), headingErr = mean(headingErr, na.rm = T)) 
offset.segMean.aligned  <- ddply(offset.segData.aligned, c("SubjectNo", "Scene", "Direction", "Block", "seg.z"), plyr::summarise, x = mean(x, na.rm = T), headingErr = mean(headingErr, na.rm = T)) 


# Draw Trial 1 data
path.trial1 <- ggplot(offset.segData.aligned[TrialNo == 1], aes(x = seg.z, y = x)) + theme_bw() +
  geom_line(data = egoline, aes(x = pred_y, y = pred_x), colour = "grey50", linetype = "5252", size = 1, show.legend = FALSE) + 
  stat_summary(fun.data = mean_cl_normal, geom = "ribbon", aes(group = Scene, fill = Scene, alpha = Scene), show.legend = FALSE) + 
  stat_summary(fun.y = "mean", geom = "line", aes(group = Scene, colour = Scene, linetype = Scene), size = 1) +
  scale_x_continuous(limits = c(0, 7), breaks = c(0, 2, 4, 6), labels = c(7, 5, 3, 1)) +
  coord_flip(ylim = c(0, 0.5)) + geom_vline(xintercept = 0) + geom_hline(yintercept = 0) +
  labs(x = "Distance to Target (m)", y = "X (m)") +
  scale_color_manual(name = "", values = c("#a6cee3", "#33a02c", "#ff7f00", "#6a3d9a")) +
  scale_fill_manual(name = "", values = c("#a6cee3", "#33a02c", "#ff7f00", "#6a3d9a")) +
  scale_alpha_manual(name = "", values = c(0.3, 0.15, 0.15, 0.3)) +
  scale_linetype_manual(name = "", values = c("solid", "3111", "11", "31")) +
  theme(panel.background = element_rect(fill = "transparent", colour = NA),
        panel.grid = element_blank(),
        panel.spacing = unit(0.75, "lines"),
        panel.border = element_blank(),
        axis.line = element_line(colour = "black"),
        plot.background = element_rect(fill = "transparent", colour = NA),
        axis.text.x = element_text(family = "Helvetica", size = 10),
        axis.text.y = element_text(family = "Helvetica", size = 10),
        axis.title = element_text(family = "Helvetica", size = 12, colour = "#595959"),
        legend.title = element_blank(),
        legend.background = element_rect(fill = "transparent", colour = NA),
        legend.key = element_rect(fill = "transparent", colour = NA),
        legend.position = "bottom",
        legend.text = element_text(family = "Helvetica", size = 12, colour = "#595959"))

err.trial1 <- ggplot(offset.segData[TrialNo == 1], aes(x = seg.z, y = headingErr)) + theme_bw() +
  geom_hline(yintercept = 10, colour = "grey50", linetype = "5252", size = 1, show.legend = FALSE) + 
  stat_summary(fun.data = mean_cl_normal, geom = "ribbon", aes(group = Scene, fill = Scene, alpha = Scene), show.legend = FALSE) + 
  stat_summary(fun.y = "mean", geom = "line", aes(group = Scene, colour = Scene, linetype = Scene), size = 1) +
  scale_x_continuous(limits = c(0, 6), breaks = c(0, 2, 4, 6), labels = c(7, 5, 3, 1)) +
  coord_cartesian(ylim = c(-5, 15)) + geom_vline(xintercept = 0) + geom_hline(yintercept = 0) +
  labs(x = "Distance to Target (m)", y = "Target-heading angle (°)") +
  scale_color_manual(name = "", values = c("#a6cee3", "#33a02c", "#ff7f00", "#6a3d9a")) + #red: "#d7191c", orange: "#fdae61", light blue: "#abd9e9", blue: "#2c7bb6"
  scale_fill_manual(name = "", values = c("#a6cee3", "#33a02c", "#ff7f00", "#6a3d9a")) +
  scale_alpha_manual(name = "", values = c(0.3, 0.15, 0.15, 0.3)) +
  # scale_size_manual(name = "", values = c(1, 2, 1, 2)) +
  scale_linetype_manual(name = "", values = c("solid", "3111", "11", "31")) +
  theme(panel.background = element_rect(fill = "transparent", colour = NA),
        panel.grid = element_blank(),
        panel.spacing = unit(0.75, "lines"),
        panel.border = element_blank(),
        axis.line = element_line(colour = "black"),
        plot.background = element_rect(fill = "transparent", colour = NA),
        axis.text.x = element_text(family = "Helvetica",size = 10),
        axis.text.y = element_text(family = "Helvetica",size = 10),
        axis.title = element_text(family = "Helvetica",size = 12, colour = "#595959"),
        legend.title = element_blank(),
        legend.background = element_rect(fill = "transparent", colour = NA),
        legend.key = element_rect(fill = "transparent", colour = NA),
        legend.key.width = unit(1.5, 'cm'),
        legend.position = "bottom",
        legend.text = element_text(family = "Helvetica", size = 12, colour = "#595959"))

prow     <- plot_grid(path.trial1 + theme(legend.position="none"), NULL, err.trial1 + theme(legend.position="none"), labels = c("a", "b", ""), label_fontfamily = "Helvetica", label_size = 18, align = "vh", nrow = 1, rel_widths = c(.4, 0.05 ,.55))
legend   <- get_legend(err.trial1)
p        <- plot_grid( prow, legend, ncol = 1, rel_heights = c(3, 0.2))
p

ggplot2::ggsave("figures/Trajectories_TargetHeadingAngle_Trial1.pdf", width=18, height=9, units = "cm") 




## Draw points as early and later parts
load(file = "Data/TwoEndLong.RData")

offset.end.long$Scene   <- factor(offset.end.long$Scene, levels(offset.end.long$Scene)[c(2, 3, 1, 4)], labels = c("Line", "Outline", "Cloud", "Room"))
offset.end.long$TrialNo <- as.numeric(offset.end.long$TrialNo)

after.end.long$Scene    <- factor(after.end.long$Scene, levels(after.end.long$Scene)[c(2, 3, 1, 4)], labels = c("Line", "Outline", "Cloud", "Room"))
after.end.long$TrialNo  <- as.numeric(after.end.long$TrialNo)

pd <- position_dodge(width = 0.5)
trial.mean.plot.offset <- ggplot(offset.end.long, aes(TrialNo, headingErr)) + theme_minimal() + geom_hline(yintercept = 0) +
  stat_summary(fun.data = "mean_cl_normal", geom = "errorbar",  width = 0.5, alpha = 0.75, position = pd, aes(group = end, colour = end)) +
  stat_summary(fun.y = "mean", geom = "point", aes(group = end, colour = end, shape = end, size = end), position = pd) +
  stat_summary(fun.y = "mean", geom = "line", aes(y = predMean, group = end, colour = end), size = 1, position = pd) +
  geom_hline(yintercept = 10, colour = "grey50", linetype = 2, size = 0.5, show.legend = FALSE) + 
  geom_vline(xintercept = 0) +
  coord_cartesian(ylim = c(-3, 12)) + scale_x_continuous(breaks = c(1:4), labels = c(5, 6, 7, 8)) +
  facet_wrap( ~ Scene, nrow = 1 ) +
  scale_color_manual(name  ="", values = c("#d7191c", "#2c7bb6") ) +
  scale_shape_manual(name = "", values = c(15, 16)) +
  scale_size_manual(name = "", values = c(3, 3)) +
  labs(x = "Trial", y = "Mean Target-heading Angle (°)") + 
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.text.x = element_text(family = "Helvetica", size = 10),
        axis.text.y = element_text(family = "Helvetica", size = 10),
        axis.title = element_text(family = "Helvetica", size = 12),
        legend.title = element_blank(),
        legend.background = element_rect(colour = NA, fill = "transparent"), 
        legend.key.width = unit(1, 'cm'), 
        legend.text = element_text(family = "Helvetica", size = 10, colour = "#595959"),
        legend.position=c(0.9, 0.1),
        legend.spacing.y = unit(0, 'cm'),
        strip.text = element_text(family = "Helvetica", size = 12, face = "bold"))

trial.mean.plot.after <- ggplot(after.end.long, aes(TrialNo, headingErr)) + theme_minimal() + geom_hline(yintercept = 0) +
  stat_summary(fun.data = "mean_cl_normal", geom = "errorbar",  width = 0.5, alpha = 0.75, position = pd, aes(group = end, colour = end)) +
  stat_summary(fun.y = "mean", geom = "point", aes(group = end, colour = end, shape = end, size = end), position = pd) +
  stat_summary(fun.y = "mean", geom = "line", aes(y = predMean, group = end, colour = end), size = 1, position = pd) +
  geom_vline(xintercept = 0) +
  coord_cartesian(ylim = c(-5, 2)) + scale_x_continuous(breaks = c(1:4), labels = c(5, 6, 7, 8)) +
  facet_wrap( ~ Scene, nrow = 1 ) +
  scale_color_manual(name  ="", values = c("#d7191c", "#2c7bb6") ) +
  scale_shape_manual(name = "", values = c(15, 16)) +
  scale_size_manual(name = "", values = c(3, 3)) +
  labs(x = "Trial", y = "Mean Target-heading Angle (°)") + 
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.text.x = element_text(family = "Helvetica", size = 10),
        axis.text.y = element_text(family = "Helvetica", size = 10),
        axis.title = element_text(family = "Helvetica", size = 12),
        legend.title = element_blank(),
        legend.background = element_rect(colour = NA, fill = "transparent"), 
        legend.key.width = unit(1, 'cm'), 
        legend.text = element_text(family = "Helvetica", size = 10, colour = "#595959"),
        legend.position=c(0.9, 0.1),
        legend.spacing.y = unit(0, 'cm'),
        strip.text = element_text(family = "Helvetica", size = 12, face = "bold"))

prow     <- plot_grid(NULL, trial.mean.plot.offset, NULL, trial.mean.plot.after, labels = c("a", "", "b", ""), label_fontfamily = "Helvetica", label_size = 18, align = "vh", nrow = 2, rel_widths = c(.15, 2, 0.15, 2))
prow

ggplot2::ggsave(paste0("figures/THA_trials_ends.pdf"), width = 16.5, height = 16, units = "cm")

