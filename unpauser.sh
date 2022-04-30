focused_window_id=$(xdotool getwindowfocus)
active_window_id=$(xdotool getactivewindow)
active_window_pid=$(xdotool getwindowpid "$active_window_id")

kill -CONT ${active_window_pid} || ps aux | grep .exe | grep Program | awk '{print $2}' | xargs -I XX sh -c 'kill -CONT XX'
