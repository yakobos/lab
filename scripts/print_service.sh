#!/bin/bash

# Antiochian Orthodox Service PDF Collector
# This script takes a main PDF (e.g., an index or booklet with hyperlinks to other service PDFs),
# extracts external PDF links using only standard tools (strings, grep, curl),
# downloads them, and places everything in a dated folder.
#
# Requirements: bash, strings (binutils), grep, sed, curl (very common, no special packages).
# No poppler, no Python, no extra installs.
#
# Usage: ./collect_service_pdfs.sh <main_pdf_file> <YYYY-MM-DD> <service>
# Example: ./collect_service_pdfs.sh "Vespers January 6.pdf" 2026-01-06 vespers

set -euo pipefail

if [ $# -ne 3 ]; then
    echo "Usage: $0 <main_pdf_file> <date YYYY-MM-DD> <service: vespers, orthros, or liturgy>"
    echo "Example: $0 \"Main Service.pdf\" 2026-01-06 vespers"
    exit 1
fi

MAIN_PDF="$1"
DATE="$2"
SERVICE="$3"

# Validate service name (lowercase only)
if [[ "$SERVICE" != "vespers" && "$SERVICE" != "orthros" && "$SERVICE" != "liturgy" ]]; then
    echo "Error: Service must be one of: vespers, orthros, liturgy"
    exit 1
fi

FOLDER="${DATE}_${SERVICE}"
mkdir -p "$FOLDER"

echo "Creating folder: $FOLDER"

# Copy the main PDF as 00_Main.pdf
cp "$MAIN_PDF" "$FOLDER/00_${SERVICE}_main.pdf"
echo "Copied main PDF as 00_${SERVICE}_main.pdf"

# Extract unique external PDF URLs (case-insensitive http/https, ending in .pdf)
# This works reliably on most PDFs because hyperlink URIs are stored as plain strings.
URLS=$(strings "$MAIN_PDF" | grep -Eio 'https?://[^[:space:]"]+\.pdf' | sort -u)

if [ -z "$URLS" ]; then
    echo "No external PDF links found in $MAIN_PDF"
    echo "Folder created with only the main PDF."
    exit 0
fi

echo "Found $(echo "$URLS" | wc -l) unique PDF link(s) to download"

count=1
while IFS= read -r url; do
    # Get the original filename from URL and clean query parameters
    base=$(basename "$url")
    filename="${base%%\?*}"  # Strip everything after ? if present

    # Sanitize filename (replace spaces and unsafe chars with underscores)
    clean_name=$(echo "$filename" | sed 's/[^a-zA-Z0-9._-]/_/g')

    # Prefix with zero-padded number for consistent ordering
    padded_name=$(printf "%02d_%s" "$count" "$clean_name")

    target="$FOLDER/$padded_name"

    echo "Downloading [$count]: $url → $padded_name"
    curl -f -L --fail-early -o "$target" "$url" || echo "    Warning: Failed to download $url"

    ((count++))
done <<< "$URLS"

echo "Done! All PDFs are in $FOLDER"
echo "Files use consistent naming: 00_main → 01_originalname.pdf → 02_etc.pdf"
