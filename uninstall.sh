#!/bin/sh

println() {
  printf '%s\n' "$1">&2
}

fatal() {
  println "fatal: $1"
  exit 1
}

ROOT="$(cd "$(dirname "$0")"&&pwd)"
PREFIX="${1%/}"
if [ -z "$PREFIX" ]; then
  if [ "$(id -u)" -eq 0 ]; then
    PREFIX=/usr/local
  else
    PREFIX="$HOME/.local"
  fi
fi

SCIP_DST="$PREFIX/bin/scip"
LIB_DST="$PREFIX/lib/scip"

if [ -L "$SCIP_DST" ]; then
  unlink "$SCIP_DST" || fatal "failed to unlink $SCIP_DST"
else
  if [ -e "$SCIP_DST" ]; then
    rm -rv "$SCIP_DST" || fatal "failed to remove $SCIP_DST"
  fi
fi

if [ -L "$LIB_DST" ]; then
  unlink "$LIB_DST" || fatal "failed to unlink $LIB_DST"
else
  if [ -e "$LIB_DST" ]; then
    rm -rv "$LIB_DST" || fatal "failed to remove $LIB_DST"
  fi
fi

println 'scip successfully uninstalled'
