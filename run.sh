#!/bin/bash
# This script is intended to be run through run.sh (https://run.jotaen.net)

PUML_OPTIONS='-Tsvg'
DS_PUML_URL='https://github.com/johthor/DomainStory-PlantUML'
LOG_LEVEL=$LOG_LEVEL

PROJECT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

strContains() { case $1 in *$2* ) return 0;; *) return 1;; esac ;}

puml::convert() {
  fileName="$1"
  outputDir="$2"

  if strContains "$fileName" "DARK_MODE"; then
    echo "Converting $fileName in dark mode to directory $outputDir"
    plantuml "$PUML_OPTIONS" -o "$PROJECT_ROOT/$outputDir" -darkmode -DPUML_MODE=dark "$fileName"
  else
    echo "Converting $fileName in light mode to directory $outputDir"
    plantuml "$PUML_OPTIONS" -o "$PROJECT_ROOT/$outputDir" "$fileName"
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

  plantuml -DLOG_LEVEL="$LOG_LEVEL" -preproc "$1"
  sed -e 's/^[ ]*//' "$fileBase.preproc" > scrapbook/preprocessed/"$fileName.preproc.puml"
  rm "$fileBase.preproc"
}

# Bake the next release version
run::bakeRelease() {
  version="$1"
  versionName="${2:-'Next Version'}"
  pathToStdLib="${3:-"$PROJECT_ROOT/../plantuml-stdlib"}"
  domainStoryDir="$pathToStdLib/stdlib/DomainStory"

  echo "Next Release $versionName with version $version will be baked into $domainStoryDir"

  # Update DomainStoryVersion
  sed -i .bak -E "s/'' Version: .+/'' Version: $version/" "$PROJECT_ROOT/domainStory.puml"
  sed -i .bak -E "s/\!global \\\$DomainStoryVersion  =  \".+\"/\!global \\\$DomainStoryVersion  =  \"$version\"/" "$PROJECT_ROOT/domainStory.puml"

  # Update Changelog
  sed -i .bak -E "s/## \[Unreleased\] - t.b.d./## \[Unreleased\] - t.b.d.\n\n\n## $versionName \[$version\] - $(date +'%Y-%m-%d')/" "$PROJECT_ROOT/CHANGELOG.md"
  sed -i .bak -E "s/\[Unreleased\]: https:\/\/github.com\/johthor\/DomainStory-PlantUML\/compare\/v.+\.\.\.HEAD/\
\[Unreleased\]: https:\/\/github.com\/johthor\/DomainStory-PlantUML\/compare\/v$version\.\.\.HEAD\n\
\[$version\]: https:\/\/github.com\/johthor\/DomainStory-PlantUML\/releases\/tag\/v$version/" "$PROJECT_ROOT/CHANGELOG.md"

  # Update StdLib README file
  sed -i .bak -E "s/version: .+/version: $version/" "$domainStoryDir/README.md"

  # Copy over relevant PUML files into StdLib
  cp "$PROJECT_ROOT/domainStory.puml" "$domainStoryDir"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  cmd="$1"
  shift

  echo "Running task run::$cmd"
  "run::$cmd" "$@"
fi
