#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;

# Script Name: basic_badge.pl
#
# Description:
#   Creates a basic SVG badge. The left side displays the name as white-on-black text,
#   and the right side displays the status as white-on-color text, with the color
#   specified by the user. Outputs the badge in SVG format to stdout.
#
# Usage:
#   ./basic_badge.pl --name <name> --status <status> --color <color>
#
# Parameters:
#   --name    - The text to display on the left side of the badge.
#   --status  - The text to display on the right side of the badge.
#   --color   - The color for the right side (e.g., 'green', '#00FF00').
#
# Example:
#   ./basic_badge.pl --name "Cygwin" --status "passing" --color "green"

# Define variables for command-line options
my $name;
my $status;
my $color;

# Parse command-line options
GetOptions(
    'name=s'   => \$name,
    'status=s' => \$status,
    'color=s'  => \$color,
) or die "Usage: $0 --name <name> --status <status> --color <color>\n";

# Validate that all parameters are provided
if (!defined $name || !defined $status || !defined $color) {
    die "Usage: $0 --name <name> --status <status> --color <color>\n" .
        "Example: $0 --name 'Cygwin' --status 'passing' --color 'green'\n";
}

# Escape special XML characters in name and status
$name = escape_xml($name);
$status = escape_xml($status);

# Calculate widths (8px per character + 20px padding)
my $name_width   = (length($name) * 8) + 20;
my $status_width = (length($status) * 8) + 20;
my $total_width  = $name_width + $status_width;
my $text_offset  = $name_width + 10;

# Output SVG to stdout
print <<EOF;
<svg xmlns="http://www.w3.org/2000/svg" width="$total_width" height="24">
  <!-- Definitions for gradients -->
  <defs>
    <!-- Gradient for black (left side) -->
    <linearGradient id="blackGradient" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#444444"/>
      <stop offset="100%" stop-color="black"/>
    </linearGradient>
    <!-- Gradient for the specified color (right side) -->
    <linearGradient id="colorGradient" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="$color" stop-opacity="0.8"/>
      <stop offset="100%" stop-color="$color"/>
    </linearGradient>
  </defs>

  <!-- Left side: black gradient rectangle with name -->
  <rect x="0" y="0" width="$name_width" height="24" fill="url(#blackGradient)"/>
  <text x="10" y="17" font-family="sans-serif" font-size="12" fill="white" style="filter: drop-shadow(1px 1px 1px rgba(0,0,0,0.3));">$name</text>
  
  <!-- Right side: colored gradient rectangle with status -->
  <rect x="$name_width" y="0" width="$status_width" height="24" fill="url(#colorGradient)"/>
  <text x="$text_offset" y="17" font-family="sans-serif" font-size="12" fill="white" style="filter: drop-shadow(1px 1px 1px rgba(0,0,0,0.3));">$status</text>
</svg>
EOF

# Subroutine to escape special XML characters
sub escape_xml {
    my ($text) = @_;
    $text =~ s/&/&amp;/g;
    $text =~ s/</&lt;/g;
    $text =~ s/>/&gt;/g;
    $text =~ s/"/&quot;/g;
    $text =~ s/'/&apos;/g;
    return $text;
}
