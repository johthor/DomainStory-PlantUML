#!/bin/bash
# This script is intended to be run through run.sh (https://run.jotaen.net)

PROJECT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# Convert all samples into assets
run::convertAssets() {
  for a in assets/*.puml; do
    echo Converting "$a"
    plantuml -Tsvg -o "$PROJECT_ROOT"/assets "$a"
  done

  for s in samples/*.puml; do
    echo Converting "$s"
    plantuml -Tsvg -o "$PROJECT_ROOT"/assets "$s"
  done
}

# Extract Table of Contents from Readme
run::extractTOC() {
  grep -e '^##' README.md
}

run::preprocessFile() {
  directory=$(dirname "$1")
  fileName=$(basename "$1" .puml)
  fileBase="$directory/$fileName"

  plantuml -preproc "$1"
  sed -e 's/^[ ]*//' "$fileBase.preproc" > scrapbook/preprocessed/"$fileName.preproc.puml"
  rm "$fileBase.preproc"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  cmd="$1"
  shift

  echo "Running task run::$cmd"
  "run::$cmd" "$@"
fi
