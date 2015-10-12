#!/bin/bash

echo $1

declare -a crimeTypeNames=("robbery_count" "shooting_count" "assault_count")
for crimeType in "${crimeTypeNames[@]}"
do
    #echo $crimeType
    bash ./parallelUpdatingScript.sh /.local/ $crimeType 10
done
