#!/bin/bash

lines=(
'                      _'
'                     | |_ _ __ ___  _   ___  __'
'                     | __| ''_ \` _ \| | | \ \/ /'
'                     | |_| | | | | | |_| |>  <'
'                      \__|_| |_| |_|\__,_/_/\_\'
''
'                ____   _____        _______ ____  _'
'               |  _ \ / _ \ \      / / ____|  _ \| |'
'               | |_) | | | \ \ /\ / /|  _| | |_) | |'
'               |  __/| |_| |\ V  V / | |___|  _ <|_|'
'               |_|    \___/  \_/\_/  |_____|_| \_(_)'
)

for line in "${lines[@]}"; do
    echo "$line"
    sleep 10
done
