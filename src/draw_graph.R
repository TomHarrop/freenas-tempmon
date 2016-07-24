#!/usr/bin/env Rscript

library(ggplot2)
library(dplyr)

# data load function
LoadSensorData <- function(sensor.file) {
  col.names <- c("time", "sensor", "serial", "temperature")
  colClasses <- c("numeric", "character", "character", "character")
  sensor.data.frame <- read.csv(sensor.file, header = FALSE,
                                col.names = col.names, colClasses = colClasses,
                                na.strings = c("", "NA"), fill = TRUE, stringsAsFactors = FALSE)
}

# load data for each sensor
sensors <- c(weather = "dat/weather.csv", disk = "dat/disk_temp.csv",
             cpu = "dat/cpu_temp.csv")
sensor.data <- dplyr::bind_rows(lapply(sensors, LoadSensorData), .id = "type")

# convert epoch time to POSIXct and convert temp to numeric
origin <- "1970-01-01"

plot.data <- sensor.data %>% mutate(
  time = as.POSIXct(time, origin = origin),
  temperature = as.numeric(sub("C", "", temperature)),
  sensor = relevel(factor(sensor), ref = unique(sensor[type == "weather"]))) %>%
  filter(!is.na(temperature))

# save plot
if (!dir.exists("out")) {
  dir.create("out")
}
pdf("out/graph.pdf")

n.disk <- length(unique(plot.data$sensor[plot.data$type == "disk"]))
n.cpu <- length(unique(plot.data$sensor[plot.data$type == "cpu"]))

c1 <- "#e41a1c"
c2 <- tail(RColorBrewer::brewer.pal(9, "Blues"), n.disk)
c3 <- tail(RColorBrewer::brewer.pal(9, "Greens"), n.cpu)

palette <- c(c1, c2, c3)

ggplot(plot.data[!plot.data$type == "weather",],
       aes(x = time, y = temperature, group = sensor, colour = sensor)) +
  facet_wrap(~sensor) +
  theme_minimal() +
  xlab("Time") + ylab("Temperature (°C)") +
  scale_color_manual(values = palette, guide = guide_legend(title = NULL)) +
  geom_line() +
  geom_line(aes(colour = c1), data = plot.data[plot.data$type == "weather",])

dev.off()