#!/bin/bash
GPU_USE=$(rocm-smi --showuse 2>/dev/null | grep "GPU use" | awk '{print $NF}' | tr -d '%')
GPU_WATTS=$(awk '{printf "%.0f", $1/1000000}' /sys/class/hwmon/hwmon2/power1_average)

if [ "$GPU_USE" -ge 80 ]; then
    CLASS="high"
elif [ "$GPU_USE" -ge 50 ]; then
    CLASS="medium"
else
    CLASS="low"
fi

echo "{\"text\": \"${GPU_USE}% ${GPU_WATTS}W 󰹑\", \"class\": \"${CLASS}\", \"tooltip\": \"GPU uso: ${GPU_USE}%\nGPU power: ${GPU_WATTS}W\"}"
