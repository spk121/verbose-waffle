#!/bin/bash

# Check if a file argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 input.txt"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="${INPUT_FILE%.txt}.svg"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' not found"
    exit 1
fi

# Calculate dimensions based on content
LINE_HEIGHT=16  # 16px per line (12pt default SVG text size)
PADDING=8       # 8px padding on all sides
CHAR_WIDTH=8    # 8px per character for monospace
TAB_WIDTH=4     # Number of spaces per tab

# Temporary file to store processed lines (for accurate width calculation)
TEMP_FILE=$(mktemp)

# Preprocess tabs to 4 spaces for consistent width calculation
while IFS= read -r line; do
    echo "$line" | sed "s/\t/$(printf ' %.0s' $(seq 1 $TAB_WIDTH))/g" >> "$TEMP_FILE"
done < "$INPUT_FILE"

# Count lines and find longest line from processed text
LINE_COUNT=$(wc -l < "$TEMP_FILE")
LONGEST_LINE=$(wc -L < "$TEMP_FILE")

# Calculate SVG dimensions
HEIGHT=$(( (LINE_COUNT * LINE_HEIGHT) + (PADDING * 2) ))
WIDTH=$(( (LONGEST_LINE * CHAR_WIDTH) + (PADDING * 2) ))

# Start SVG file with white-space: pre
cat > "$OUTPUT_FILE" << EOF
<svg xmlns="http://www.w3.org/2000/svg" width="$WIDTH" height="$HEIGHT">
  <rect width="$WIDTH" height="$HEIGHT" rx="4" ry="4" fill="black" />
  <text font-family="monospace" fill="white" alignment-baseline="baseline" style="white-space: pre">
EOF

# Process each line
LINE_NUM=0
while IFS= read -r line; do
    # Convert tabs to 4 spaces
    line=$(echo "$line" | sed "s/\t/$(printf ' %.0s' $(seq 1 $TAB_WIDTH))/g")
    # Escape special XML characters
    line=$(echo "$line" | sed "s/&/\&/g; s/</\</g; s/>/\>/g; s/\"/\\\"/g; s/'/\'/g")
    
    Y_POS=$((PADDING + (LINE_NUM * LINE_HEIGHT) + LINE_HEIGHT))
    echo "    <tspan x=\"$PADDING\" y=\"$Y_POS\">$line</tspan>" >> "$OUTPUT_FILE"

    LINE_NUM=$((LINE_NUM + 1))
done < "$INPUT_FILE"

# Close SVG tags
cat >> "$OUTPUT_FILE" << EOF
  </text>
</svg>
EOF

# Clean up temporary file
rm "$TEMP_FILE"

echo "SVG file created: $OUTPUT_FILE"
