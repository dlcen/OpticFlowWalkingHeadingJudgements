library(data.table); library(ggplot2); library(showtext); library(Hmisc); library(cowplot); 

load("Data/GenderAnalysis.RData")

# Overlapping the trajectories of male and female participants

## Get the data ready 
offset.segData <- segData_aligned[Block %in% c(2, 4, 6, 8)]
# offset.segMean <- offset.segData[, .(headingErr = mean(headingErr, na.rm = T)), by = c("SubjectNo", "Scene", "Block", "seg.z", "segNo", "Gender")]

offset.segData$Scene <- droplevels(offset.segData$Scene)
offset.segData$Scene <- factor(offset.segData$Scene, levels = levels(offset.segData$Scene)[c(2, 3, 1, 4)], labels = c("Cloud", "Line", "Outline", "Room"))

# droplevels(offset.segMean$Scene)
# offset.segMean$Scene <- factor(offset.segMean$Scene, labels = c("Cloud", "Line", "Outline", "Room"))
# offset.segMean$Scene <- factor(offset.segMean$Scene, levels = levels(offset.segMean$Scene)[c(2, 3, 1, 4)])

## Get the reference lines ready
source("egolineCal.R")
egoline <- egolineCal(prismDeg = 10, distance = 7)

## Plot the data
path.trial1 <- ggplot(offset.segData[TrialNo == 1], aes(x = seg.z, y = x)) + theme_bw() +
  geom_line(data = egoline, aes(x = pred_y, y = pred_x), colour = "grey50", linetype = "5252", size = 1, show.legend = FALSE) + 
  stat_summary(fun.data = mean_cl_normal, geom = "ribbon", aes(group = Gender, fill = Gender), alpha = 0.2, show.legend = FALSE) + 
  stat_summary(fun.y = "mean", geom = "line", aes(group = Gender, colour = Gender), size = 1) +
  scale_x_continuous(limits = c(0, 7), breaks = c(0, 2, 4, 6), labels = c(7, 5, 3, 1)) +
  coord_flip(ylim = c(0, 0.7)) + geom_vline(xintercept = 0) + geom_hline(yintercept = 0) +
  labs(x = "Distance to Target (m)", y = "X (m)") +
  # scale_color_manual(name = "", values = c("#a6cee3", "#33a02c", "#ff7f00", "#6a3d9a")) +
  # scale_fill_manual(name = "", values = c("#a6cee3", "#33a02c", "#ff7f00", "#6a3d9a")) +
  # scale_alpha_manual(name = "", values = c(0.3, 0.15, 0.15, 0.3)) +
  # scale_linetype_manual(name = "", values = c("solid", "3111", "11", "31")) +
  facet_wrap( ~ Scene) +
  theme(panel.background = element_rect(fill = "transparent", colour = NA),
        panel.grid = element_blank(),
        panel.spacing = unit(0.75, "lines"),
        panel.border = element_blank(),
        axis.line = element_line(colour = "black"),
        plot.background = element_rect(fill = "transparent", colour = NA),
        axis.text.x = element_text( size = 10),
        axis.text.y = element_text( size = 10),
        axis.title = element_text( size = 12, colour = "#595959"),
        legend.title = element_blank(),
        legend.background = element_rect(fill = "transparent", colour = NA),
        legend.key = element_rect(fill = "transparent", colour = NA),
        legend.position = "bottom",
        legend.text = element_text( size = 12, colour = "#595959"))

err.trial1 <- ggplot(offset.segData[TrialNo == 1], aes(x = seg.z, y = headingErr)) + theme_bw() +
  geom_hline(yintercept = 10, colour = "grey50", linetype = "5252", size = 1, show.legend = FALSE) + 
  stat_summary(fun.data = mean_cl_normal, geom = "ribbon", aes(group = Gender, fill = Gender), alpha = 0.2, show.legend = FALSE) + 
  stat_summary(fun.y = "mean", geom = "line", aes(group = Gender, colour = Gender), size = 1) +
  scale_x_continuous(limits = c(0, 6), breaks = c(0, 2, 4, 6), labels = c(7, 5, 3, 1)) +
  coord_cartesian(ylim = c(-5, 15)) + geom_vline(xintercept = 0) + geom_hline(yintercept = 0) +
  labs(x = "Distance to Target (m)", y = "Target-heading angle (°)") +
  # scale_color_manual(name = "", values = c("#a6cee3", "#33a02c", "#ff7f00", "#6a3d9a")) + #red: "#d7191c", orange: "#fdae61", light blue: "#abd9e9", blue: "#2c7bb6"
  # scale_fill_manual(name = "", values = c("#a6cee3", "#33a02c", "#ff7f00", "#6a3d9a")) +
  # scale_alpha_manual(name = "", values = c(0.3, 0.15, 0.15, 0.3)) +
  # # scale_size_manual(name = "", values = c(1, 2, 1, 2)) +
  # scale_linetype_manual(name = "", values = c("solid", "3111", "11", "31")) +
  facet_wrap( ~ Scene) +
  theme(panel.background = element_rect(fill = "transparent", colour = NA),
        panel.grid = element_blank(),
        panel.spacing = unit(0.75, "lines"),
        panel.border = element_blank(),
        axis.line = element_line(colour = "black"),
        plot.background = element_rect(fill = "transparent", colour = NA),
        axis.text.x = element_text(size = 10),
        axis.text.y = element_text(size = 10),
        axis.title = element_text(size = 12, colour = "#595959"),
        legend.title = element_blank(),
        legend.background = element_rect(fill = "transparent", colour = NA),
        legend.key = element_rect(fill = "transparent", colour = NA),
        legend.key.width = unit(1.5, 'cm'),
        legend.position = "bottom",
        legend.text = element_text( size = 12, colour = "#595959"))

prow     <- plot_grid(path.trial1 + theme(legend.position="none"), NULL, err.trial1 + theme(legend.position="none"), labels = c("a", "b", ""), label_size = 18, align = "vh", nrow = 1, rel_widths = c(.4, 0.05 ,.55))
legend   <- get_legend(err.trial1)
p        <- plot_grid( prow, legend, ncol = 1, rel_heights = c(3, 0.2))
p


ggsave("figures/GenderEffectsOnTrjsAndTHAs.png", width=32, height=16, units = "cm") 


