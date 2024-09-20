#!/usr/bin/env bash

# Prepare output folders
mkdir -p ./output/0-flat
mkdir -p ./output/1-resized
mkdir -p ./output/2-png
mkdir -p ./output/3-jpg
mkdir -p ./output/4-other
mkdir -p ./output/5-webp/png
mkdir -p ./output/5-webp/jpg
mkdir -p ./output/5-webp/other
mkdir -p ./output/6-lqip/png
mkdir -p ./output/6-lqip/jpg
mkdir -p ./output/6-lqip/other

# Flatten the inputs
# https://stackoverflow.com/a/20800032 👍
echo "---------------"
echo "Flatten the inputs"
echo ""

input="./input"
output="./output/0-flat"
find $input -type f | while read line; do
    # Takes a file path
    # Change all "/ . _" before the file extension to "-"
    # Rm the "--input" from the front
    dirout=$(dirname "${line}" | tr -s "[:blank:]" "-" | tr "[:upper:]" "[:lower:]" | tr -s "_" "-" | tr -s "." "-" | tr -s "/" "-")
    fileout=$(basename "${line}" | tr -s "[:blank:]" "-" | tr "[:upper:]" "[:lower:]" | tr -s "_" "-")
    fileout=$(echo "${dirout}-${fileout}" | sed 's/^-input-//')

    echo $line
    echo "-> ${fileout}"
    echo ""

    cp "${line}" "${output}/${fileout}"
done

echo "---------------"
echo "Take all images and resize them to a max of 6000px^2"
echo ""
pnpx sharp-cli -i ./output/0-flat/*.* -o ./output/1-resized --quality 85 --optimise -- resize 6000 --withoutEnlargement || exit

echo "---------------"
echo "Optimise pngs"
echo ""
pnpm exec imagemin ./output/1-resized/*.png -o ./output/2-png --plugin=pngquant

echo "---------------"
echo "Optimise jpegs"
echo ""
pnpm exec imagemin ./output/1-resized/*.jpg -o ./output/3-jpg --plugin=mozjpeg
pnpm exec imagemin ./output/1-resized/*.jpeg -o ./output/3-jpg --plugin=mozjpeg

echo "---------------"
echo "Optimise anything else"
echo ""
pnpm exec imagemin ./output/1-resized/*.* !./output/1-resized/*.png !./output/1-resized/*.jpg -o ./output/4-other

echo "---------------"
echo "Webp everything"
echo ""
pnpx sharp-cli -i ./output/2-png/*.* -o ./output/5-webp/png -f webp --quality 85 --optimise
pnpx sharp-cli -i ./output/3-jpg/*.* -o ./output/5-webp/jpg -f webp --quality 85 --optimise
pnpx sharp-cli -i ./output/4-other/*.* -o ./output/5-webp/other -f webp --quality 85 --optimise

echo "---------------"
echo "Lqip everything"
echo ""
pnpx sharp-cli -i ./output/5-webp/png/*.* -o ./output/6-lqip/png -f webp --quality 85 --optimise --quality=5 blur 1.5 -- resize 1000 --withoutEnlargement
pnpx sharp-cli -i ./output/5-webp/jpg/*.* -o ./output/6-lqip/jpg -f webp --quality 85 --optimise --quality=5 blur 1.5 -- resize 1000 --withoutEnlargement
pnpx sharp-cli -i ./output/5-webp/other/*.* -o ./output/6-lqip/other -f webp --quality 85 --optimise --quality=5 blur 1.5 -- resize 1000 --withoutEnlargement

# Done?!
echo ""
echo "---------------"
echo "Hooray!"
