#!/usr/bin/env bash

# ref: https://mikeshade.com/posts/keychron-linux-function-keys/

# Use Fn + X + L (hold for 4 seconds) to set the function key row to “Function” mode. (usually all that’s necessary on Windows)

echo 0 | sudo tee /sys/module/hid_apple/parameters/fnmode
