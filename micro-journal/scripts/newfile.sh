#!/bin/bash

# Get the current date and time in the format YYYY.MM.DD-HHMM
filename=$(date +"%Y.%m.%d-%H%M.wg")

# Run WordGrinder with the generated filename
wordgrinder "documents/$filename"
