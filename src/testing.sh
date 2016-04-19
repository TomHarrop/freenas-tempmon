#!/bin/sh

set -eu

# get the number of cpus from sysctl
number_cpus="$(sysctl -a 'hw.ncpu' | cut -w -f2)"
end=$((number_cpus - 1))

# print the temperature from each cpu sensor
for i in $(seq 0 $end); do
	cpu_sensor="dev.cpu.$i.temperature"
	# NA is for consistent output with disk loop
	cat -t <<- _EOF_
		$(date +%s),cpu.$i,NA,$(sysctl -a "$cpu_sensor" | cut -w -f2)
_EOF_
done

# get a list of connected disks
disks=$(sysctl -a 'kern.geom.disk' | cut -d '.' -f4)

# print the serial and temperature for each disk
# this is the only part of the script that needs root
for i in $disks; do
	temp="$(smartctl -A /dev/"$i" | grep "Temperature_Celsius" | cut -w -f10)"
	serial="$(smartctl -i /dev/"$i" | grep "Serial Number" | cut -w -f3)"
	cat -t <<- _EOF_
		$(date +%s),$i,$serial,$temp
_EOF_
done
