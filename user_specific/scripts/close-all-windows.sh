#!/bin/bash

# Get the list of open windows
windows=$(i3-msg -t get_tree | jq '.. | objects | select(.window) | .window_properties | .class' | grep -v "i3")

# Close each window
for window in $windows; do
    i3-msg "[class=$window] kill"
    echo "killed window[${window}]"
done
