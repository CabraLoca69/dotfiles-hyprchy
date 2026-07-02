#!/bin/bash
ENERGY_FILE=/sys/class/hwmon/hwmon3/energy9_input

E1=$(cat $ENERGY_FILE)
CPU1=$(grep -m1 'cpu ' /proc/stat)
sleep 1
E2=$(cat $ENERGY_FILE)
CPU2=$(grep -m1 'cpu ' /proc/stat)

WATTS=$(awk "BEGIN {printf \"%.1f\", ($E2-$E1)/1000000}")

IDLE1=$(echo $CPU1 | awk '{print $5}')
TOTAL1=$(echo $CPU1 | awk '{print $2+$3+$4+$5+$6+$7+$8}')
IDLE2=$(echo $CPU2 | awk '{print $5}')
TOTAL2=$(echo $CPU2 | awk '{print $2+$3+$4+$5+$6+$7+$8}')

CPU_PCT=$(awk "BEGIN {printf \"%.0f\", (1 - ($IDLE2-$IDLE1)/($TOTAL2-$TOTAL1)) * 100}")

FREQ=$(awk '{printf "%.0f", $1/1000}' /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null)
TEMP=$(cat /sys/class/hwmon/hwmon4/temp1_input 2>/dev/null)
TEMP=$(awk "BEGIN {printf \"%.0f\", $TEMP/1000}")


if [ "$CPU_PCT" -ge 80 ]; then
    CLASS="high"
elif [ "$CPU_PCT" -ge 50 ]; then
    CLASS="medium"
else
    CLASS="low"
fi

echo "{\"text\": \"${CPU_PCT}% ${WATTS}W 󰍛\", \"class\": \"${CLASS}\", \"tooltip\": \"CPU Temp: ${TEMP}°C\nFreq: ${FREQ} MHz\"}"