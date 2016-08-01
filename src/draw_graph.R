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
plot.data <- plot.data %>% mutate(sensor = factor(sensor))

# pick a date
today <- Sys.time() - 86400
plot.data <- plot.data %>% filter(strftime(time, format = "%j") >= strftime(today, format = "%j"))

# make weather data for superimposing
weather.data <- filter(plot.data, type == "weather")
MutateWeather <- function(sensor.name){
  mutate(weather.data, sensor = sensor.name)
}
mutated.list <- lapply(as.character(unique(filter(
  plot.data, !type == "weather")$sensor)), MutateWeather)
weather.plot <- dplyr::bind_rows(mutated.list)

# set colours
n.disk <- length(unique(plot.data$sensor[plot.data$type == "disk"]))
n.cpu <- length(unique(plot.data$sensor[plot.data$type == "cpu"]))
break.labels <- levels(plot.data$sensor)

c1 <- "#e41a1c"
c2 <- tail(RColorBrewer::brewer.pal(9, "Blues"), n.disk)
c3 <- tail(RColorBrewer::brewer.pal(9, "Greens"), n.cpu)
palette <- c(c1, c2, c3)

# save plot
if (!dir.exists("out")) {
  dir.create("out")
}

pdf("out/graph.pdf", width = 10, height = 7.5)
ggplot(filter(plot.data, !type == "weather"),
             aes(x = time, y = temperature, group = sensor, colour = sensor)) +
  facet_wrap(~sensor) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
        axis.ticks.length = unit(0, "mm")) +
  xlab("Time") + ylab("Temperature (°C)") +
  scale_color_manual(values = palette, breaks = break.labels,
                     labels = break.labels, drop = FALSE,
                     guide = guide_legend(title = NULL),
                     expand = c(0, 0)) +
  geom_line() +
  geom_line(mapping = aes(colour = type), data = weather.plot, colour = c1)

dev.off()