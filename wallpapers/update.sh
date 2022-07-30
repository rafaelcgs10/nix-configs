set -e

cd ~/nix-configs/wallpapers

while :
do
    w=$(xrandr | grep '*' | awk -F ' ' '{print $1}' | awk -F 'x' '{print $1}' | tail -n 1)
    w2=$(expr 2 \* $w)
    h=$(xrandr | grep '*' | awk -F ' ' '{print $1}' | awk -F 'x' '{print $2}' | tail -n 1)
    h2=$(expr 2 \* $h)

    l=$(expr 3 \* $w2 / 7 \- 50)
    r=$(expr 2 \* $l / 3 \- 90)

    angle=$(awk -v n=1 -v seed="$RANDOM" 'BEGIN { srand(seed); for (i=0; i<n; ++i) printf("%.4f\n", rand() + 1) }')

    pscircle \
        --background-color=1e2226 \
        --link-color-min=375143a0 \
        --link-color-max=375143 \
        --dot-color-min=7c762f \
        --dot-color-max=b56e46 \
        --tree-font-size=20 \
        --tree-font-color=94bfd1 \
        --tree-font-face="mononoki" \
        --root-pid=1 \
        --max-children=10 \
        --tree-sector-angle=1.7 \
        --tree-rotate=true \
        --tree-rotation-angle=1.8\
        --tree-center=-$l:$r \
        --cpulist-center=-$l:-900 \
        --memlist-center=-$l:-650 \
        --output-width=$w2 \
        --output-height=$h2 \
        --output=$HOME/nix-configs/wallpapers/process.jpeg

    convert -font mononoki-Regular -pointsize 20 -fill yellow -draw "text 1600,1400 \" `echo "ERRORS:"; journalctl --since "60 min ago" -p err..alert | tail -n 5` \"" process.jpeg process_2.jpeg || true
    convert -font mononoki-Regular -pointsize 20 -fill "#9ba798" -draw "text 1600,1550 \" `echo "LOGS:"; journalctl --since "10 min ago" | tail -n 20` \"" process_2.jpeg process_3.jpeg || true
    convert <( curl -s wttr.in/copenhagen_background=1e2226.png ) -resize 125% weather_report.png || true
    convert process_3.jpeg weather_report.png -geometry +1400+100 -composite process_4.jpeg || true

    feh $HOME/nix-configs/wallpapers/process_4.jpeg --bg-scal
    sleep 5
done
