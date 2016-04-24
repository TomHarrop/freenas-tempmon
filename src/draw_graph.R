library(ggplot2)
library(data.table)

# load data
col.names <- c("time", "sensor", "serial", "temperature")
colClasses <- c("numeric", "character", "character", "character")
sensor.data <- data.table(read.csv("dat/sample.csv", header = FALSE, col.names = col.names,
                                   colClasses = colClasses, na.strings = c("", "NA"),
                                   fill = TRUE, stringsAsFactors = FALSE))

# convert epoch time to POSIXct
origin <- "1970-01-01"
sensor.data[, time := as.POSIXct(time, origin = origin)]

# fix temperature readings
sensor.data[, temperature := as.numeric(sub("C", "", temperature))]

# split disk vs cpu
sensor.data[grep("^cpu", sensor), type := "cpu"]
sensor.data[is.na(type), type := "disk"]

# plot
ggplot(sensor.data[!is.na(temperature)], aes(x = time, y = temperature, group = sensor, colour = sensor)) +
#  facet_wrap(~type, ncol = 1) +
  scale_color_discrete() +
  geom_smooth(method = "glm", se = FALSE, size = 0.5, alpha = 0.7) +
  geom_point(size = 3, alpha = 0.7)