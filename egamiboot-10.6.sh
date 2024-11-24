#!/bin/bash

# 
hostname=$(hostname)
echo "YOUR DEVICE IS: $hostname"

#
opkg_path="/etc/opkg"
oldpkg_path="$opkg_path/oldpkg"
lists_path="/var/lib/opkg/lists"
egami_file_path="$lists_path/egami-$hostname"

# 
if [[ ! -d "$opkg_path" || ! -d "$lists_path" ]]; then
  echo "Error: Required directories do not exist."
  exit 1
fi

# 
mkdir -p "$oldpkg_path"

#
echo "Backing up current opkg configuration..."
for file in "$opkg_path"/*; do
  [[ -f "$file" ]] && cp "$file" "$oldpkg_path/"
done

#
echo "Modifying opkg configuration files..."
for file in "$opkg_path"/*; do
  [[ -f "$file" ]] && sed -i 's/10\.6/10\.5/g' "$file"
done

#
echo "Updating feeds..."
if ! opkg update >/dev/null 2>&1; then
  echo "Error: Failed to update feeds."
  exit 1
fi

# 
if [[ ! -f "$egami_file_path" ]]; then
  echo "Error: The file $egami_file_path does not exist."
  exit 1
fi

echo "Found file: $egami_file_path"
content=$(cat "$egami_file_path")

# 
package_names=(
  "egami-base-files_1.0"
  "egamibm_1.0-"
  "egamiinit_1.0-"
  "enigma2-plugin-extensions-egamiboot_10.5"
)

urls=()
while IFS= read -r line; do
  if [[ "$line" == Filename:* ]]; then
    filename=$(echo "$line" | awk '{print $2}')
    for package in "${package_names[@]}"; do
      if [[ "$filename" == "$package"* && "$filename" == *.ipk ]]; then
        urls+=("http://egami-feed.com/feeds/egami/10.5/$hostname/$hostname/$filename")
      fi
    done
  fi
done <<< "$content"

if [[ ${#urls[@]} -eq 0 ]]; then
  echo "No packages found in the file."
  exit 1
fi

#
echo "Downloading packages..."
downloaded_files=()
for url in "${urls[@]}"; do
  filename="/tmp/$(basename "$url")"
  if curl -s "$url" -o "$filename"; then
    echo "Downloaded: $(basename "$url")"
    downloaded_files+=("$filename")
  else
    echo "Error: Failed to download $url"
  fi
done

#
echo "Installing packages..."
for file in "${downloaded_files[@]}"; do
  if opkg install --force-reinstall "$file" >/dev/null 2>&1; then
    echo "Installed: $(basename "$file")"
  else
    echo "Error: Failed to install $(basename "$file")"
  fi
done

#
echo "Restoring original files..."
for file in "$oldpkg_path"/*; do
  [[ -f "$file" ]] && sed -i 's/10\.5/10\.6/g' "$file" && cp "$file" "$opkg_path/"
done

#
echo "Cleaning up..."
rm -rf "$oldpkg_path"

#
for file in "${downloaded_files[@]}"; do
  rm -f "$file"
  echo "Removed: $(basename "$file")"
done

#
echo "Updating feeds again..."
opkg update >/dev/null 2>&1

# 
TARGET_PATH="/usr/lib/enigma2/python/Plugins/Extensions/EGAMIBoot"
if [[ -d "$TARGET_PATH" ]]; then
  echo "Changing permissions for: $TARGET_PATH"
  chmod -R 755 "$TARGET_PATH"
else
  echo "Error: The path $TARGET_PATH does not exist."
  exit 1
fi

# 
INPUT_FILE="$TARGET_PATH/egamiboot.mvi"
TEMP_VIDEO="/tmp/temp_video.mpg"
EXTRACTED_IMAGE="/tmp/extracted_image.jpg"
RESIZED_IMAGE="/tmp/resized_image.jpg"
OUTPUT_VIDEO="/tmp/output_video.mpg"
OUTPUT_FILE="$INPUT_FILE"

#
echo "Backing up the input file..."
cp -f "$INPUT_FILE" "$INPUT_FILE.bak" || { echo "Error: Failed to backup input file."; exit 1; }

#
echo "Processing video..."
cp -f "$INPUT_FILE" "$TEMP_VIDEO" && \
ffmpeg -i "$TEMP_VIDEO" -frames:v 1 "$EXTRACTED_IMAGE" >/dev/null 2>&1 && \
ffmpeg -i "$EXTRACTED_IMAGE" -vf scale=1280:720 "$RESIZED_IMAGE" >/dev/null 2>&1 && \
ffmpeg -loop 1 -i "$RESIZED_IMAGE" -c:v mpeg1video -t 1 "$OUTPUT_VIDEO" >/dev/null 2>&1 && \
mv "$OUTPUT_VIDEO" "$OUTPUT_FILE" || { echo "Error: Video processing failed."; exit 1; }

#
echo "Cleaning temporary files..."
rm -f "$TEMP_VIDEO" "$EXTRACTED_IMAGE" "$RESIZED_IMAGE"

echo "Process completed successfully."
killall -9 enigma2


