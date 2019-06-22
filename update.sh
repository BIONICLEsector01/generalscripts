#!/bin/bash

echo "Updating BIONICLEsector01.com"
echo "#############################"

echo "Updating splash page"
cd /home/swert/biosector01.com/
git pull

echo "Updating HTTP error pages"
cd /home/swert/biosector01.com/errors
git pull

echo "Done!"
