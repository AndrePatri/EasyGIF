# Copyright (C) 2023  Andrea Patrizi (AndrePatri, andreapatrizi1b6e6@gmail.com)
# 
# This file is part of EasyGIF and distributed under the General Public License version 2 license.
# 
# EasyGIF is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# EasyGIF is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with EasyGIF.  If not, see <http://www.gnu.org/licenses/>.
# 
#!/bin/bash

# Ensure correct number of arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 /path/to/pngs max_size_in_MB /path/to/output.gif"
    exit 1
fi

# Extract arguments
IMAGE_PATH="$1"
MAX_SIZE_MB="$2"
MAX_SIZE_BYTES=$(( MAX_SIZE_MB * 1024 * 1024 ))
OUTPUT_PATH="$3"

# Ask user for input factor
while true; do
    read -p "Enter input factor (<= 1): " input_factor
    if (( $(echo "$input_factor <= 1 && $input_factor > 0" | bc -l) )); then
        break
    else
        echo "Please enter a valid input factor between 0 and 1."
    fi
done

# Calculate the skip interval based on the input factor
interval=$(echo "1 / $input_factor" | bc)

# Convert PNGs to GIFs using ImageMagick
png_files=("$IMAGE_PATH"/*.png)
total_pngs=${#png_files[@]}
reduced_total=$(echo "$total_pngs * $input_factor" | bc | cut -f1 -d.)

echo "Converting PNGs to GIFs using a factor of $input_factor..."
count=0
processed=0

for img in "${png_files[@]}"; do
    if ((count % interval == 0)); then
        mogrify -format gif "$img"
        processed=$((processed + 1))
        echo "Remaining conversions: $((reduced_total - processed))/$reduced_total"
    fi
    count=$((count + 1))
done

# Create an animated GIF using Gifsicle
echo "Generating GIF..."
gifsicle --delay=10 --loop "$IMAGE_PATH"/*.gif > temp.gif

# Check file size
FILE_SIZE=$(stat -c%s "temp.gif")

# Optimize the GIF until it's under the desired size
echo "Optimizing GIF..."
while [ $FILE_SIZE -gt $MAX_SIZE_BYTES ]; do
    gifsicle -O3 --colors 256 --lossy=30 temp.gif -o temp_optimized.gif
    mv temp_optimized.gif temp.gif
    FILE_SIZE=$(stat -c%s "temp.gif")
done

# Move the final GIF to the desired location
mv temp.gif "$OUTPUT_PATH"

# Clean up individual GIF frames
rm "$IMAGE_PATH"/*.gif

echo "GIF created at $OUTPUT_PATH"

