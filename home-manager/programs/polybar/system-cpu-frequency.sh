#!/bin/sh

c=0;t=0

~/.nix-profile/bin/gawk '/MHz/ {print $4}' < /proc/cpuinfo | (while read -r i
do
    t=$( echo "$t + $i" | ~/.nix-profile/bin/bc )
    c=$((c+1))
done
echo "scale=2; $t / $c / 1000" | ~/.nix-profile/bin/bc | ~/.nix-profile/bin/gawk '{print " " $0" GHz"}')
