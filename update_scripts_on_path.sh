#!/bin/bash

# Define the source and destination directories
SOURCE_DIR="./scripts"
DEST_DIR="$HOME/scripts"

# Create the destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Copy all scripts from the source to the destination, overwriting any existing files
cp -r "$SOURCE_DIR/"* "$DEST_DIR/"

# ensure the scripts are executable
chmod +x "$DEST_DIR"/*