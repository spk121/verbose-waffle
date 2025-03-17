# Script Name: Basic-Badge.ps1
#
# Description:
#   Creates a basic SVG badge. The left side displays the first argument as white-on-black text,
#   and the right side displays the second argument as white-on-color text, with the color
#   specified by the third argument. Outputs the badge in SVG format to stdout.
#
# Usage:
#   .\New-Badge.ps1 -Name <name> -Status <status> -Color <color>
#
# Parameters:
#   Name    - The text to display on the left side of the badge.
#   Status  - The text to display on the right side of the badge.
#   Color   - The color for the right side of the badge (e.g., 'green', '#00FF00').
#
# Example:
#   .\New-Badge.ps1 -Name "Cygwin" -Status "passing" -Color "green"

# Define parameters
param (
    [Parameter(Mandatory=$true)][string]$Name,
    [Parameter(Mandatory=$true)][string]$Status,
    [Parameter(Mandatory=$true)][string]$Color
)

# Check for correct number of arguments
if ($PSBoundParameters.Count -ne 3) {
    Write-Error "Usage: .\New-Badge.ps1 -Name <name> -Status <status> -Color <color>"
    Write-Error "Example: .\New-Badge.ps1 -Name 'Cygwin' -Status 'passing' -Color 'green'"
    exit 1
}

# Calculate text widths (approximate: 8px per character for 12pt font, plus padding)
$NameWidth = ($Name.Length * 8 + 20)  # 8px per char + 20px padding
$StatusWidth = ($Status.Length * 8 + 20)  # 8px per char + 20px padding
$TotalWidth = $NameWidth + $StatusWidth
$TextOffset = $NameWidth + 10  # 10px padding for status text

# SVG content as a here-string, output to stdout
Write-Output @"
<svg xmlns="http://www.w3.org/2000/svg" width="$TotalWidth" height="24">
  <!-- Definitions for gradients -->
  <defs>
    <!-- Gradient for black (left side) -->
    <linearGradient id="blackGradient" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#444444"/>
      <stop offset="100%" stop-color="black"/>
    </linearGradient>
    <!-- Gradient for the specified color (right side) -->
    <linearGradient id="colorGradient" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="$Color" stop-opacity="0.8"/>
      <stop offset="100%" stop-color="$Color"/>
    </linearGradient>
  </defs>

  <!-- Left side: black gradient rectangle with name -->
  <rect x="0" y="0" width="$NameWidth" height="24" fill="url(#blackGradient)"/>
  <text x="10" y="17" font-family="sans-serif" font-size="12" fill="white" style="filter: drop-shadow(1px 1px 1px rgba(0,0,0,0.3));">$Name</text>
  
  <!-- Right side: colored gradient rectangle with status -->
  <rect x="$NameWidth" y="0" width="$StatusWidth" height="24" fill="url(#colorGradient)"/>
  <text x="$TextOffset" y="17" font-family="sans-serif" font-size="12" fill="white" style="filter: drop-shadow(1px 1px 1px rgba(0,0,0,0.3));">$Status</text>
</svg>
"@
