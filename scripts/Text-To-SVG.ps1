# Script Name: Text-To-SVG.ps1
#
# Description:
#   Takes pre-rendered, line-delimited text from stdin (pipeline input)
#   and converts it to an SVG representation, preserving spacing and lines.
#   Outputs the SVG to stdout.
#
# Usage:
#   Get-Content file.txt | .\Text-To-SVG.ps1
#   echo "text" | .\Text-To-SVG.ps1
#
# Notes:
#   - Assumes monospace font with 8px per character and 16px line height.
#   - Tabs are rendered with a tab-size of 4 spaces.
#   - Special XML characters (&, <, >, ", ') are escaped.

# Define constants
$LINE_HEIGHT = 16  # 16px per line (12pt default SVG text size)
$PADDING = 8       # 8px padding on all sides
$CHAR_WIDTH = 8    # 8px per character for monospace
$TAB_WIDTH = 4     # Number of spaces per tab (for width calculation)

# Read all input from pipeline into an array of lines.
# Ignore empty lines.
$lines = ($input -split "\r?\n") | Where-Object { $_ }

# Calculate dimensions based on content
$lineCount = $lines.Count
if ($lineCount -eq 0) {
    $lines = @("")  # Ensure at least one empty line if no input
    $lineCount = 1
}

# Find longest line, accounting for tabs as $TAB_WIDTH spaces
$spaces = " " * $TAB_WIDTH  # Generate $TAB_WIDTH spaces
$longestLineLength = 0
foreach ($line in $lines) {
    $expandedLine = $line -replace "`t", $spaces
    $lineLength = $expandedLine.Length
    if ($lineLength -gt $longestLineLength) {
        $longestLineLength = $lineLength
    }
}

# Calculate SVG dimensions
$height = ($lineCount * $LINE_HEIGHT) + ($PADDING * 2)
$width = ($longestLineLength * $CHAR_WIDTH) + ($PADDING * 2)

# Start SVG output with here-string
$svgHeader = @"
<svg xmlns="http://www.w3.org/2000/svg" width="$width" height="$height">
  <rect width="$width" height="$height" rx="4" ry="4" fill="black" />
  <text font-family="monospace" fill="white" alignment-baseline="baseline" style="white-space: pre; tab-size: $TAB_WIDTH;">
"@

# Process each line and create <tspan> elements
$svgBody = ""
$lineNum = 0
foreach ($line in $lines) {
    # Escape special XML characters
    $escapedLine = $line -replace "&", "&amp;" `
                        -replace "<", "&lt;" `
                        -replace ">", "&gt;" `
                        -replace '"', "&quot;" `
                        -replace "'", "&apos;"
    
    $yPos = $PADDING + ($lineNum * $LINE_HEIGHT) + $LINE_HEIGHT
    $svgBody += "    <tspan x=`"$PADDING`" y=`"$yPos`">$escapedLine</tspan>`n"
    $lineNum++
}

# Close SVG tags
$svgFooter = @"
  </text>
</svg>
"@

# Output the complete SVG to stdout
Write-Output $svgHeader
Write-Output $svgBody
Write-Output $svgFooter
