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
    temperature = as.numeric(sub("C", "", temperature))) %>%
    filter(!is.na(temperature))

# save plot
if (!dir.exists("out")) {
    dir.create("out")
}
pdf("out/graph.pdf")
ggplot(plot.data,
    aes(x = time, y = temperature, group = sensor, colour = sensor)) +
    theme_minimal() +
    scale_color_discrete() +
    geom_smooth(method = "glm", se = FALSE, size = 0.5, alpha = 0.7) +
    geom_point(size = 3, alpha = 0.7)
dev.off()