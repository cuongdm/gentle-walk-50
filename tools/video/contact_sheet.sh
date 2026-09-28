#!/bin/bash
# Contact sheet of a clip for visual review. Usage: contact_sheet.sh clip.mp4 out.png [fps=2] [cols=4] [rows=4]
ffmpeg -v error -y -i "$1" -vf "fps=${3:-2},scale=480:-1,tile=${4:-4}x${5:-4}" -frames:v 1 "$2"
