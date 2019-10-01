DEBUG=0
INFO=1
WARN=2
ERROR=3
FATAL=4
NONE=5

LF="$(printf '\n_')";LF="${LF%_}"

parse_level() {
  case "$1" in
    [dD][eE][bB][uU][gG]|$DEBUG) echo $DEBUG;;
    [iI][nN][fF][oO]|$INFO) echo $INFO;;
    [wW][aA][rR][nN]|$WARN) echo $WARN;;
    [eE][rR][rR][oO][rR]|$ERROR) echo $ERROR;;
    [fF][aA][tT][aA][lL]|$FATAL) echo $FATAL;;
    [nN][oO][nN][eE]|$NONE) echo $NONE;;
    *) echo $INFO;;
  esac
}

level_str() {
  case "$1" in
    $DEBUG) echo debug;;
    $INFO) echo info;;
    $WARN) echo warn;;
    $ERROR) echo error;;
    $FATAL) echo fatal;;
  esac
}

println() {
  printf '%s\n' "$1"
}

log() {
  set -- $1 "$(level_str "$1")" "$2"
  if [ $1 -ge $PRINT_LEVEL ]; then
    printf '%s(%s): %s\n' "$SCIP_SIDE" "$2" "$3">&2
  fi
  if [ $1 -ge $LOG_LEVEL ]; then
    (printf '%s - %s [%s] %s\n' "$(date +'%Y-%m-%d %T')" "$SCIP_SCOPE" "$2" "$3">>"$LOG_FILE") 2>/dev/null
    if [ $? -ne 0 ]; then
      LOG_LEVEL=$NONE
      error "failed to write log file: $LOG_FILE"
    fi
  fi
}

debug() {
  log $DEBUG "$1"
}

info() {
  log $INFO "$1"
}

warn() {
  log $WARN "$1"
}

error() {
  log $ERROR "$1"
}

fatal() {
  log $FATAL "$1"
  exit 1
}

mkdirp() {
  if [ -d "$1" ]; then
    return 0
  fi
  if [ -e "$1" ]; then
    return 1
  fi
  (
    PARENT="$(dirname "$1")"
    case "$PARENT" in
      /|.);;
      *) mkdirp "$PARENT" || return 1;;
    esac
  )
  mkdir "$1"
}

init_log_dir() {
  if [ "$_LOG_LEVEL" -lt $NONE ];  then
    if mkdirp "$LOG_DIR"; then
      LOG_LEVEL="$_LOG_LEVEL"
    else
      warn "failed to create log directory: $LGO_DIR"
    fi
  fi
}

LOG_LEVEL=$NONE
PRINT_LEVEL="$(parse_level "$SCIP_PRINT_LEVEL")"

_LOG_LEVEL="$(parse_level "$SCIP_LOG_LEVEL")"

if [ -z "$XDG_CACHE_HOME" ]; then
  XDG_CACHE_HOME="$HOME/.cache"
fi

CACHE_DIR="${XDG_CACHE_HOME%/}/scip"
LOG_DIR="$CACHE_DIR/log"
LOG_FILE="$LOG_DIR/$SCIP_SIDE.log"

debug "LOG_LEVEL  : $_LOG_LEVEL"
debug "PRINT_LEVEL: $PRINT_LEVEL"
debug "LOG_DIR    : $LOG_DIR"
debug "LOG_FILE   : $LOG_FILE"
