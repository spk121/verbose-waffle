#!/usr/bin/env perl
use strict;
use warnings;
use open ':std', ':encoding(UTF-8)';

# Script Name: Text-To-SVG.pl
#
# Description:
#   Takes pre-rendered, line-delimited text from stdin (pipeline input)
#   and converts it to an SVG representation, preserving spacing and lines.
#   Outputs the SVG to stdout.
#
# Usage:
#   cat file.txt | ./Text-To-SVG.pl
#   echo "text" | ./Text-To-SVG.pl
#
# Notes:
#   - Handles rare Unicode line terminators: U+0085 (NEL), U+2028 (LS), U+2029 (PS).
#   - Assumes monospace font with 8px per character and 16px line height.
#   - Tabs are rendered with a tab-size of 4 spaces.
#   - Special XML characters (&, <, >, ", ') are escaped.

# Define constants
my $LINE_HEIGHT = 16;  # 16px per line (12pt default SVG text size)
my $PADDING = 8;       # 8px padding on all sides
my $CHAR_WIDTH = 8;    # 8px per character for monospace
my $TAB_WIDTH = 4;     # Number of spaces per tab (for width calculation)

# Read all input from stdin into a string
my $input = do { local $/; <STDIN> };

# Split the input into lines using a regex that handles all line terminators
my @lines = split /(?:\r\n)|[\n\r\x{0085}\x{2028}\x{2029}]/, $input;
# Filter out empty lines
@lines = grep { length $_ } @lines;
# If no lines remain, add one empty line
if (scalar @lines == 0) {
    @lines = ("");
}

# Calculate dimensions based on content
my $line_count = scalar @lines;

# Find the longest line, accounting for tabs as $TAB_WIDTH spaces
my $spaces = ' ' x $TAB_WIDTH;
my $longest_line_length = 0;
foreach my $line (@lines) {
    my $expanded_line = $line =~ s/\t/$spaces/gr;
    my $line_length = length($expanded_line);
    if ($line_length > $longest_line_length) {
        $longest_line_length = $line_length;
    }
}

# Calculate SVG dimensions
my $height = ($line_count * $LINE_HEIGHT) + ($PADDING * 2);
my $width = ($longest_line_length * $CHAR_WIDTH) + ($PADDING * 2);

# Generate SVG header
my $svg_header = <<EOF;
<svg xmlns="http://www.w3.org/2000/svg" width="$width" height="$height">
  <rect width="$width" height="$height" rx="4" ry="4" fill="black" />
  <text font-family="monospace" fill="white" alignment-baseline="baseline" style="white-space: pre; tab-size: $TAB_WIDTH;">
EOF

# Process each line and create <tspan> elements
my $svg_body = "";
my $line_num = 0;
foreach my $line (@lines) {
    my $escaped_line = escape_xml($line);
    my $y_pos = $PADDING + ($line_num * $LINE_HEIGHT) + $LINE_HEIGHT;
    $svg_body .= "    <tspan x=\"$PADDING\" y=\"$y_pos\">$escaped_line</tspan>\n";
    $line_num++;
}

# Generate SVG footer
my $svg_footer = <<EOF;
  </text>
</svg>
EOF

# Output the complete SVG to stdout
print $svg_header;
print $svg_body;
print $svg_footer;

# Subroutine to escape special XML characters
sub escape_xml {
    my ($text) = @_;
    $text =~ s/&/\&/g;
    $text =~ s/</\</g;
    $text =~ s/>/\>/g;
    $text =~ s/"/\"/g;
    $text =~ s/'/\'/g;
    return $text;
}
