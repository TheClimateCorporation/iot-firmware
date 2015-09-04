#!/usr/bin/env bash
script=${1:-'motion.lua'}
echo "uploading" $script
../nodemcu-uploader/nodemcu-uploader.py -p /dev/cu.SLAB_USBtoUART upload motion-detector/$script:$script
