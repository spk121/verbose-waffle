# This script takes pre-rendered text from stdin (pipeline input)
# and converts it to an SVG representation of the prerendered text on stdout.

# Calculate dimensions based on content
$LINE_HEIGHT = 16  # 16px per line (12pt default SVG text size)
$PADDING = 8       # 8px padding on all sides
$CHAR_WIDTH = 8    # 8px per character for monospace
$TAB_WIDTH = 4     # Number of spaces per tab (for width calculation)

# Read all input from pipeline into an array
$inputLines = @($input)

# Count lines and find longest line, accounting for tabs as 4 spaces
$LINE_COUNT = $inputLines.Count
# Replace tabs with $TAB_WIDTH spaces for width calculation
$SPACES = " " * $TAB_WIDTH  # Generate $TAB_WIDTH spaces
$LONGEST_LINE = ($inputLines | ForEach-Object { $_ -replace "\t", $SPACES } | Measure-Object -Property Length -Maximum).Maximum

# Calculate SVG dimensions
$HEIGHT = ($LINE_COUNT * $LINE_HEIGHT) + ($PADDING * 2)
$WIDTH = ($LONGEST_LINE * $CHAR_WIDTH) + ($PADDING * 2)

# Start SVG output to stdout with tab-size: 4
Write-Output "<svg xmlns=`"http://www.w3.org/2000/svg`" width=`"$WIDTH`" height=`"$HEIGHT`">"
Write-Output "  <rect width=`"$WIDTH`" height=`"$HEIGHT`" rx=`"4`" ry=`"4`" fill=`"black`" />"
Write-Output "  <text font-family=`"monospace`" fill=`"white`" alignment-baseline=`"baseline`" style=`"white-space: pre; tab-size: $TAB_WIDTH;`">"

# Process each line from input content
$LINE_NUM = 0
foreach ($line in $inputLines) {
    # Escape special XML characters (no tab substitution needed here)
    $line = $line -replace "&", "&amp;" `
                  -replace "<", "&lt;" `
                  -replace ">", "&gt;" `
                  -replace '"', "&quot;" `
                  -replace "'", "&apos;"
    
    $Y_POS = $PADDING + ($LINE_NUM * $LINE_HEIGHT) + $LINE_HEIGHT
    Write-Output "    <tspan x=`"$PADDING`" y=`"$Y_POS`">$line</tspan>"

    $LINE_NUM++
}

# Close SVG tags
Write-Output "  </text>"
Write-Output "</svg>"
