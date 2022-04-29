focused_window_id=$(xdotool getwindowfocus)
active_window_id=$(xdotool getactivewindow)
active_window_pid=$(xdotool getwindowpid "$active_window_id")

kill -CONT ${active_window_pid}
