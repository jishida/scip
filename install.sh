#!/bin/sh

println() {
  printf '%s\n' "$1">&2
}

fatal() {
  println "$1"
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

ROOT="$(cd "$(dirname "$0")"&&pwd)"
PREFIX="${1%/}"
if [ -z "$PREFIX" ]; then
  if [ "$(id -u)" -eq 0 ]; then
    PREFIX=/usr/local
  else
    PREFIX="$HOME/.local"
  fi
fi

SCIP_SRC="$ROOT/bin/scip"
LIB_SRC="$ROOT/lib/scip"

SCIP_DST_DIR="$PREFIX/bin"
LIB_DST_DIR="$PREFIX/lib"

SCIP_DST="$SCIP_DST_DIR/scip"
LIB_DST="$LIB_DST_DIR/scip"

if [ -e "$SCIP_DST" ]; then
  fatal "$SCIP_DST already exists"
else
  mkdirp "$SCIP_DST_DIR" || fatal "failed to create $SCIP_DST_DIR"
fi

if [ -e "$LIB_DST" ]; then
  fatal "$LIB_DST already exists"
else
  mkdirp "$LIB_DST_DIR" || fatal "failed to create $LIB_DST_DIR"
fi

cp -v "$SCIP_SRC" "$SCIP_DST" || fatal "failed to copy $SCIP_SRC to $SCIP_DST"
cp -rv "$LIB_SRC" "$LIB_DST" || fatal "failed to copy $LIB_SRC to $LIB_DST"
chmod +x "$SCIP_DST" || fatal "failed to add executable flag to $SCIP_DST"

println 'scip successfully installed'
