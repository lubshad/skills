# Helper function to run flutter with optional watch mode
run_flutter_with_watch() {
  local command_array=("$@")
  
  if [ "${WATCH_MODE:-true}" = true ]; then
    printf 'Starting in watch mode (requires fswatch)...\n'
    if [ -r /dev/tty ]; then
      "${command_array[@]}" < /dev/tty &
    else
      "${command_array[@]}" &
    fi
    FLUTTER_PID=$!
    # fswatch monitors lib/ and signals SIGUSR1 to the flutter process for hot reload
    fswatch -o lib/ | xargs -n1 -I{} kill -SIGUSR1 "$FLUTTER_PID" 2>/dev/null &
    WATCHER_PID=$!
    trap 'kill "$FLUTTER_PID" "$WATCHER_PID" 2>/dev/null; exit' INT TERM
    wait "$FLUTTER_PID"
    kill "$WATCHER_PID" 2>/dev/null
  else
    "${command_array[@]}"
  fi
}
