#!/bin/bash

# This script creates a basic badge.
# On the left is the first argument printed as white-on-black text.
# on the right is the second argument printed as white-on-color text,
# where the color is given in the 3rd argument.
# It outputs the badge in SVG format to stdout.

# Check if correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <name> <status> <color>" >&2
    echo "Example: $0 'Cygwin' 'passing' 'green'" >&2
    exit 1
fi

# Assign arguments to variables
NAME="$1"
STATUS="$2"
COLOR="$3"

# Calculate text widths (approximate: 8px per character for 12pt font, plus padding)
NAME_WIDTH=$(( ${#NAME} * 8 + 20 ))  # 8px per char + 20px padding
STATUS_WIDTH=$(( ${#STATUS} * 8 + 20 ))  # 8px per char + 20px padding
TOTAL_WIDTH=$(( NAME_WIDTH + STATUS_WIDTH ))
TEXT_OFFSET=$(( NAME_WIDTH + 10 ))  # 10px padding for status text

# SVG with gradients and standard rectangles
cat << EOF
<svg xmlns="http://www.w3.org/2000/svg" width="$TOTAL_WIDTH" height="24">
  <!-- Definitions for gradients -->
  <defs>
    <!-- Gradient for black (left side) -->
    <linearGradient id="blackGradient" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#444444"/>
      <stop offset="100%" stop-color="black"/>
    </linearGradient>
    <!-- Gradient for the specified color (right side) -->
    <linearGradient id="colorGradient" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="$COLOR" stop-opacity="0.8"/>
      <stop offset="100%" stop-color="$COLOR"/>
    </linearGradient>
  </defs>

  <!-- Left side: black gradient rectangle with name -->
  <rect x="0" y="0" width="$NAME_WIDTH" height="24" fill="url(#blackGradient)"/>
  <text x="10" y="17" font-family="sans-serif" font-size="12" fill="white" style="filter: drop-shadow(1px 1px 1px rgba(0,0,0,0.3));">$NAME</text>
  
  <!-- Right side: colored gradient rectangle with status -->
  <rect x="$NAME_WIDTH" y="0" width="$STATUS_WIDTH" height="24" fill="url(#colorGradient)"/>
  <text x="$TEXT_OFFSET" y="17" font-family="sans-serif" font-size="12" fill="white" style="filter: drop-shadow(1px 1px 1px rgba(0,0,0,0.3));">$STATUS</text>
</svg>
EOF
