# Verbose Waffle

Verbose Waffle is a set of shell scripts and batch scripts to generate
"badges", those small images that say if a build is passing or failing.

## Features
- A script for simple badges with custom text
- A script for badges that report test failure counts
- A script that converts preformatted text into images
- TODO: Cross-platform - most scripts come as shell and as bat

## Installation
This project requires no installation and has no dependencies.
Each shell script or batch script is standalone.
There is no makefile or install script for this project.
Just clone or download the project and run the script.

## Usage
Quick examples of how to run the scripts.
- Basic badge: ./scripts/basic.sh "My Project" "passing" "green" > badge.svg
- Text to SVG: ./scripts/txt2svg.sh < input.txt > output.svg
- TODO: Note: "See `docs/usage.md` for advanced options."

## Directory Structure
- `scripts/`: Core shell and batch scripts.
- `inputs/`: Sample text files for testing.
- TODO: `outputs/`: Example generated images.
- TODO: `docs/`: Detailed documentation.

## Examples
Showcase the tool in action.
- Input: `inputs/test1.txt`
→ Output: `outputs/test1_output.png` (optionally embed an image: `![Sample](outputs/test1_output.png)`).
- Command: `./scripts/generate.sh inputs/test2.txt outputs/test2.jpg`

## Contributing
How others can help (optional but common).
- "Pull requests welcome! See `docs/contributing.md` for guidelines."
- "Report bugs in the Issues tab."

## License
They are pretty simple scripts so I'm feel odd even giving them
a license, but LGPL 2.1+, I suppose.  `LICENSE` file for details.

## Acknowledgments
- Credit: Thanks to everyone who wrote the Github docs and the SVG docs.
