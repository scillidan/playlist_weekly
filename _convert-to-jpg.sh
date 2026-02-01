#!/bin/bash

find . -name "*.pdf" -type f | while read -r pdf_file; do
    magick -density 300 "$pdf_file[0]" -resize x1080 -background white -alpha remove -quality 90 "${pdf_file%.pdf}.pdf.jpg"
done