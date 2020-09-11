#!/bin/sh

# If a command fails then the deploy stops
set -e

printf "\033[0;32mDeploying updates to GitHub...\033[0m\n"
cd docs && rm -rf * 
cd ..
cp CNAME docs
cd _hugo
# Build the project.
hugo -t reveal-hugo # if using a theme, replace with `hugo -t <YOURTHEME>`

# Go To Public folder
mv public/* ../docs