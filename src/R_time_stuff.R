# get number of cpus (freebsd)
`sysctl -a 'hw.ncpu' | cut -w -f2`

# get list of disks (freebsd)
`sysctl -a 'kern.geom.disk' | cut -d '.' -f4`

# get cpu temperature
`sysctl -a 'dev.cpu.7.temperature' | cut -w -f2`

# example cpu temperature line
`echo "$(date +%s)","dev.cpu.7.temperature","$(sysctl -a 'dev.cpu.7.temperature' | cut -w -f2)"`

# get disk serial
`smartctl -i /dev/ada0 | grep "Serial Number" | cut -w -f3`

# get disk temperature (needs root)
`smartctl -A /dev/ada0 | grep "Temperature_Celsius" | cut -w -f10`

# example disk temperature line
echo "$(date +%s)","/dev/ada0","$(smartctl -A /dev/ada0 | grep "Temperature_Celsius" | cut -w -f10)"

# specify the origin for epoch time
origin = "1970-01-01"

# get the system time zone (not necessary)
tz <- format(Sys.time(), "%Z")

# get the epoch time with bash
`date +%s`
# in R
now <- as.numeric(format(Sys.time(), "%s"))

# convert epoch time to POSIXct
as.POSIXct(now, origin = origin)

pd <- data.frame(
  time = as.POSIXct(c(1459947742:1459948347), origin = origin),
  y = rnorm(606))
apply(pd, 2, class)
ggplot(pd, aes(x = time, y = y)) + geom_point()

