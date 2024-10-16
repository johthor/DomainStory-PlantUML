#!/bin/bash

PROJECT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# Convert all samples into assets
run::convertAssets() {
  for s in samples/*.puml; do
    echo Converting $s
    plantuml -Tsvg -o $PROJECT_ROOT/assets $s
  done
}

# Extract Table of Contents from Readme
run::extractTOC() {
  grep -e ^\## README.md | grep -v 'Table of Contents'
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && "run::$@"
