set -e

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
        --tree-font-size=24 \
        --tree-font-color=94bfd1 \
        --tree-font-face="mononoki" \
        --root-pid=1 \
        --max-children=10 \
        --tree-sector-angle=1.7 \
        --tree-rotate=true \
        --tree-rotation-angle=1.7 \
        --tree-center=-$l:$r \
        --cpulist-center=$r:-200 \
        --memlist-center=$r:200 \
        --output-width=$w2 \
        --output-height=$h2 \
    --output=$HOME/nix-configs/wallpapers/process.jpeg

    feh $HOME/nix-configs/wallpapers/process.jpeg --bg-scal
	sleep 10
done
