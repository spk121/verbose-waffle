#!/bin/bash

# This script takes pre-rendered text from stdin
# and converts it to an SVG representation of the
# prerendered text on stdout.


# Calculate dimensions based on content
LINE_HEIGHT=16  # 16px per line (12pt default SVG text size)
PADDING=8       # 8px padding on all sides
CHAR_WIDTH=8    # 8px per character for monospace
TAB_WIDTH=4     # Number of spaces per tab (for width calculation)

# Read all input from stdin into a temporary file for processing
TEMP_FILE=$(mktemp)
cat > "$TEMP_FILE"

# Count lines and find longest line, accounting for tabs as 4 spaces
LINE_COUNT=$(wc -l < "$TEMP_FILE")
# Replace tabs with $TAB_WIDTH spaces for width calculation
SPACES=$(printf '%*s' "$TAB_WIDTH" '')  # Generate $TAB_WIDTH spaces
LONGEST_LINE=$(sed "s/\t/$SPACES/g" "$TEMP_FILE" | wc -L)

# Calculate SVG dimensions
HEIGHT=$(( (LINE_COUNT * LINE_HEIGHT) + (PADDING * 2) ))
WIDTH=$(( (LONGEST_LINE * CHAR_WIDTH) + (PADDING * 2) ))

# Start SVG output to stdout with tab-size: 4
cat << EOF
<svg xmlns="http://www.w3.org/2000/svg" width="$WIDTH" height="$HEIGHT">
  <rect width="$WIDTH" height="$HEIGHT" rx="4" ry="4" fill="black" />
  <text font-family="monospace" fill="white" alignment-baseline="baseline" style="white-space: pre; tab-size: $TAB_WIDTH;">
EOF

# Process each line from original stdin content
LINE_NUM=0
while IFS= read -r line; do
    # Escape special XML characters (no tab substitution needed)
    line=$(echo "$line" | sed "s/&/\&/g; s/</\</g; s/>/\>/g; s/\"/\"/g; s/'/\'/g")
    
    Y_POS=$((PADDING + (LINE_NUM * LINE_HEIGHT) + LINE_HEIGHT))
    echo "    <tspan x=\"$PADDING\" y=\"$Y_POS\">$line</tspan>"

    LINE_NUM=$((LINE_NUM + 1))
done < "$TEMP_FILE"

# Close SVG tags
cat << EOF
  </text>
</svg>
EOF

# Clean up temporary file
rm "$TEMP_FILE"
