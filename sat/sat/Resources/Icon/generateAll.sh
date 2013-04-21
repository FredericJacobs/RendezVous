#!/usr/bin/env bash
img=$1
convert $img -resize 72x72 Icon-72.png
convert $img  -resize 50x50 Icon-Small-50.png
convert $img  -resize 29x29 Icon-Small.png
convert  $img -resize 58x58 Icon-Small@2x.png
convert $img -resize 57x57  Icon.png
convert $img -resize 114x114  Icon@2x.png