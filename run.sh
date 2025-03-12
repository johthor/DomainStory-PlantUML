#!/usr/bin/env bash
# This script is intended to be run through run.sh (https://run.jotaen.net)
shopt -s globstar

PUML_OPTIONS='-Tsvg'
LOG_LEVEL="${LOG_LEVEL:-info}"

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

run::rewritePUML() {
  TARGET_DIR="${1:-test/puml}"
  IN_PLACE="$2"

  for diagram in "$TARGET_DIR"/**/*.puml ; do
    fileNameWithoutExt=$(basename "$diagram" .puml)
    subPath=$(dirname "$diagram")
    testSubject="$subPath/$fileNameWithoutExt"

    if [[ ! "$testSubject" =~ .+REWRITTEN ]]; then
      /usr/bin/env python3 tools/rewrite.py "$testSubject".puml > "$testSubject".REWRITTEN.puml
      if [ "$IN_PLACE" ]; then
        mv "$testSubject".REWRITTEN.puml "$testSubject".puml
      fi
    fi
  done
}

# Compile split source files into one PUML file
run::compile() {
  {
    cat src/header.iuml
    echo ''
    cat src/utilities.iuml
    echo ''
    cat src/storyLayout.iuml
    echo ''
    cat src/styling.iuml
    echo ''
    cat src/theming.iuml
    echo ''
    cat src/state.iuml
    echo ''
    cat src/elements.iuml
    echo ''
    cat src/actors.iuml
    echo ''
    cat src/objects.iuml
    echo ''
    cat src/boundaries.iuml
    echo ''
    cat src/activities.iuml
    echo ''
    cat src/notes.iuml
    echo ''
    cat src/helper.iuml
  } > domainStory.puml
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

  puml::convert test/puml/styling/theme-bluegray.puml docs/assets

  for asset in docs/assets/*.svg; do
    xmllint --format "$asset" > "$asset".tmp
    mv "$asset".tmp "$asset"
  done
}

run::compare() {
  magick compare -metric MAE \
    "$1" \
    "$2" \
    null: 2>&1
}

run::compareImages() {
  source ./test/lib/testUtils.sh
  export SHARNESS_TEST_DIRECTORY="$PROJECT_ROOT/test"
  compareImages "diagrams/$1" .svg
}

run::computeDiff() {
  source ./test/lib/testUtils.sh
  export SHARNESS_TEST_DIRECTORY="$PROJECT_ROOT/test"
  computeDiff "diagrams/$1" .svg
}

# Run tests in ./test
run::test() {
  set -e

  mkdir -p test/lib

  if [ ! -f test/lib/plantuml.version ]
  then
    tag=$(curl -s https://api.github.com/repos/plantuml/plantuml/releases/latest | jq -r '.tag_name')
    echo "$tag" > test/lib/plantuml.version
  fi

  if [ ! -f test/lib/plantuml.jar ]
  then
    version=$(cat test/lib/plantuml.version)
    curl "https://github.com/plantuml/plantuml/releases/download/${version}/plantuml-${version#v}.jar" -L -o test/lib/plantuml.jar
  fi

  chmod +x test/testSuite.sh

  cd test
  ./testSuite.sh
}

# Clean tests in ./test
run::test-clean() {
  set -e
  chmod +x test/testSuite.sh

  cd test
  ./testSuite.sh clean
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


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  cmd="$1"
  shift

  echo "Running task run::$cmd"
  "run::$cmd" "$@"
fi
