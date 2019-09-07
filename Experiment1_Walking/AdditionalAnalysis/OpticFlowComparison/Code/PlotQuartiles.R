library(data.table); library(ggplot2)

quartiles <- read.csv('quartiles.csv', header = TRUE)
quartiles <- data.table(quartiles)

# Remove those without any dots
quartiles <- quartiles[Mean != 0]
quartiles$q_up <- quartiles$Mean + quartiles$Interquartile
quartiles$q_dn <- quartiles$Mean - quartiles$Interquartile
quartiles$rb   <- quartiles$Eccentricity - quartiles$EccentricityWidth
quartiles$lb   <- quartiles$Eccentricity + quartiles$EccentricityWidth

# Plot the quartiles
ggplot(data = quartiles, aes(x = Eccentricity, y = Mean)) +
	geom_rect(mapping = aes(xmin = rb, xmax = lb, ymin = q_dn, ymax = q_up), color = NA, fill = "grey30", alpha = 0.5) +
	geom_point(size = 2, color = "black") + 
	facet_wrap( ~ Scene, ncol = 2) +
	labs( x = 'Eccentricity (degree)', y = 'Mean speed magnitude (degree/s)')

ggsave("../Figures/Interquartiles.png", width=12, height=12, units = "cm") 

