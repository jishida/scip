if [ -f "$LOG_FILE" ]; then
  cat "$LOG_FILE"
else
  println 'log file not found'
fi
