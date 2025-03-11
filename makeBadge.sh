#!/bin/bash

# Check if exactly 4 arguments are provided
if [ $# -ne 4 ]; then
    echo "Usage: $0 <platform> <compile_status> <test_failures> <test_errors>"
    echo "Example: $0 MINGW32 1 0 0"
    exit 1
fi

PLATFORM="$1"          # e.g., "MINGW32"
COMPILE_STATUS="$2"    # 1 (success) or 0 (failure)
TEST_FAILURES="$3"     # Number of test failures
TEST_ERRORS="$4"       # Number of test errors
OUTPUT_FILE="status_${PLATFORM}.svg"

# Validate numeric arguments
if ! [[ "$COMPILE_STATUS" =~ ^[0-1]$ ]] || ! [[ "$TEST_FAILURES" =~ ^[0-9]+$ ]] || ! [[ "$TEST_ERRORS" =~ ^[0-9]+$ ]]; then
    echo "Error: Compile status must be 0 or 1, test failures and errors must be non-negative integers"
    exit 1
fi

# SVG dimensions and styling
CHAR_WIDTH=8    # 8px per character for monospace
LINE_HEIGHT=16  # 16px per line
PADDING=8       # 8px padding
TEXT_Y=$((PADDING + LINE_HEIGHT))

# Function to calculate text width
calc_width() {
    echo $((${#1} * CHAR_WIDTH))
}

# Initial SVG setup with platform name (white text on black)
PLATFORM_WIDTH=$(calc_width "$PLATFORM")
SVG_WIDTH=$((PLATFORM_WIDTH + (PADDING * 2)))
SVG_HEIGHT=$((LINE_HEIGHT + (PADDING * 2)))

cat > "$OUTPUT_FILE" << EOF
<svg xmlns="http://www.w3.org/2000/svg" width="$SVG_WIDTH" height="$SVG_HEIGHT">
  <rect width="$SVG_WIDTH" height="$SVG_HEIGHT" rx="4" ry="4" fill="black" />
  <text x="$PADDING" y="$TEXT_Y" font-family="monospace" fill="white" alignment-baseline="baseline">$PLATFORM</text>
EOF

# Determine status and append corresponding SVG elements
X_POS=$((PADDING + PLATFORM_WIDTH))

if [ "$COMPILE_STATUS" -eq 0 ]; then
    # Case 5: Compilation failure (white on red)
    STATUS="Compilation failure"
    STATUS_WIDTH=$(calc_width "$STATUS")
    SVG_WIDTH=$((X_POS + STATUS_WIDTH + PADDING))
    cat >> "$OUTPUT_FILE" << EOF
  <rect x="$X_POS" y="$PADDING" width="$STATUS_WIDTH" height="$LINE_HEIGHT" fill="red" />
  <text x="$X_POS" y="$TEXT_Y" font-family="monospace" fill="white" alignment-baseline="baseline">$STATUS</text>
EOF
else
    # Compile succeeded, check test results
    if [ "$TEST_FAILURES" -eq 0 ] && [ "$TEST_ERRORS" -eq 0 ]; then
        # Case 1: Pass (white on green)
        STATUS="pass"
        STATUS_WIDTH=$(calc_width "$STATUS")
        SVG_WIDTH=$((X_POS + STATUS_WIDTH + PADDING))
        cat >> "$OUTPUT_FILE" << EOF
  <rect x="$X_POS" y="$PADDING" width="$STATUS_WIDTH" height="$LINE_HEIGHT" fill="green" />
  <text x="$X_POS" y="$TEXT_Y" font-family="monospace" fill="white" alignment-baseline="baseline">$STATUS</text>
EOF
    elif [ "$TEST_FAILURES" -gt 0 ] && [ "$TEST_ERRORS" -eq 0 ]; then
        # Case 2: Fail with failures (white on dark orange)
        STATUS="fail $TEST_FAILURES"
        STATUS_WIDTH=$(calc_width "$STATUS")
        SVG_WIDTH=$((X_POS + STATUS_WIDTH + PADDING))
        cat >> "$OUTPUT_FILE" << EOF
  <rect x="$X_POS" y="$PADDING" width="$STATUS_WIDTH" height="$LINE_HEIGHT" fill="#FF8C00" />
  <text x="$X_POS" y="$TEXT_Y" font-family="monospace" fill="white" alignment-baseline="baseline">$STATUS</text>
EOF
    elif [ "$TEST_FAILURES" -eq 0 ] && [ "$TEST_ERRORS" -gt 0 ]; then
        # Case 3: Error with errors (white on reddish-brown)
        STATUS="error $TEST_ERRORS"
        STATUS_WIDTH=$(calc_width "$STATUS")
        SVG_WIDTH=$((X_POS + STATUS_WIDTH + PADDING))
        cat >> "$OUTPUT_FILE" << EOF
  <rect x="$X_POS" y="$PADDING" width="$STATUS_WIDTH" height="$LINE_HEIGHT" fill="#8B4513" />
  <text x="$X_POS" y="$TEXT_Y" font-family="monospace" fill="white" alignment-baseline="baseline">$STATUS</text>
EOF
    else
        # Case 4: Both failures and errors (fail on dark orange, error on reddish-brown)
        FAIL_STATUS="fail $TEST_FAILURES"
        ERROR_STATUS="error $TEST_ERRORS"
        FAIL_WIDTH=$(calc_width "$FAIL_STATUS")
        ERROR_WIDTH=$(calc_width "$ERROR_STATUS")
        ERROR_X=$((X_POS + FAIL_WIDTH))
        SVG_WIDTH=$((ERROR_X + ERROR_WIDTH + PADDING))
        cat >> "$OUTPUT_FILE" << EOF
  <rect x="$X_POS" y="$PADDING" width="$FAIL_WIDTH" height="$LINE_HEIGHT" fill="#FF8C00" />
  <text x="$X_POS" y="$TEXT_Y" font-family="monospace" fill="white" alignment-baseline="baseline">$FAIL_STATUS</text>
  <rect x="$ERROR_X" y="$PADDING" width="$ERROR_WIDTH" height="$LINE_HEIGHT" fill="#8B4513" />
  <text x="$ERROR_X" y="$TEXT_Y" font-family="monospace" fill="white" alignment-baseline="baseline">$ERROR_STATUS</text>
EOF
    fi
fi

# Update SVG width and close
sed -i "s/width=\"[0-9]*\"/width=\"$SVG_WIDTH\"/" "$OUTPUT_FILE"
echo "</svg>" >> "$OUTPUT_FILE"

echo "SVG file created: $OUTPUT_FILE"
