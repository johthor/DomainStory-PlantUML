#!/bin/bash
# This script is intended to be run through run.sh (https://run.jotaen.net)

PROJECT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

strContains() { case $1 in *$2* ) return 0;; *) return 1;; esac ;}

puml::convert() {
  fileName="$1"
  outputDir="$2"

  if strContains "$fileName" "DARK_MODE"; then
    echo "Converting $fileName in dark mode to directory $outputDir"
    plantuml -Tsvg -o "$PROJECT_ROOT/$outputDir" -darkmode -DPUML_MODE=dark "$fileName"
  else
    echo "Converting $fileName in light mode to directory $outputDir"
    plantuml -Tsvg -o "$PROJECT_ROOT/$outputDir" "$fileName"
  fi
}

# Convert all samples and assets
run::convertAssets() {
  set -e
  for asset in docs/puml/*.puml; do
    puml::convert "$asset" docs/assets
  done

  for sample in samples/*.puml; do
    puml::convert "$sample" docs/assets
  done

  puml::convert test/styling/theme-sketchy.puml docs/assets
}

# Extract Table of Contents from Readme
run::extractTOC() {
  grep -e '^##' README.md
}

run::processFileDark() {
  directory=$(dirname "$1")
  fileName=$(basename "$1" .puml)
  fileBase="$directory/$fileName"

  plantuml -Tsvg -darkmode -DPUML_MODE=dark -DLOG_LEVEL=debug "$1"
  mv "$fileBase.svg" scrapbook/darkmode/
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
