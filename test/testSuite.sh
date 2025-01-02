#!/usr/bin/env bash

shopt -s globstar

TEST_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

TEST_FILES=$(find "$TEST_ROOT" -type f -name '*.test.sh' | sort)
LIB_DIR='lib'
PLANTUML_CMD="java -jar $LIB_DIR/plantuml.jar"
SHARNESS_DIR='sharness'
AGGREGATE="$LIB_DIR/$SHARNESS_DIR/tools/aggregate-results.sh"

DIAGRAM_FORMAT='svg'

test::all() {
  test::aggregate "$@"
}

test::clean() {
  test::clean-test-results "$@"
  echo "*** ${FUNCNAME[0]} ***"
  # Clean binaries below.
  # For example:
  # -rm -rf bin/ipfs
  rm -f diagrams/**/*.actual.*
  rm -f diagrams/**/*._COMPARISON.*
  rm -f diagrams/**/*._COMPOSITE.*
  rm -f diagrams/**/*._FLICKER.*
  rm -f diagrams/**/*._STATS.*
  rm -f preprocessed/**/*.actual.*
  rm -f preprocessed/**/*._DIFF.*
}

test::clean-test-results() {
  echo "*** ${FUNCNAME[0]} ***"
  rm -rf test-results
  rm -rf trash\ directory*
}

test::run-tests() {
  test::clean-test-results "$@"
  test::check-sharness "$@"
  test::check-deps "$@"
  test::preprocess-all "$@"
  test::generate-all puml "$@"
  test::generate-all puml-smetana "$@"
  echo "*** ${FUNCNAME[0]} ***"
  for testFile in $TEST_FILES ; do
    DIAGRAM_FORMAT=$DIAGRAM_FORMAT $testFile
  done
}

test::aggregate() {
  test::clean-test-results "$@"
  test::run-tests "$@"
  echo "*** ${FUNCNAME[0]} ***"
  find test-results -name '*.test.sh.*.counts' | $AGGREGATE
}

test::preprocess-all() {
  pumlDir="${1:-puml}"
  echo "*** ${FUNCNAME[0]} $pumlDir ***"

  $PLANTUML_CMD -preproc -r "$TEST_ROOT/$pumlDir/**/*.puml"

  for old in "$TEST_ROOT/$pumlDir"/**/*.preproc; do
    new=$(echo "$old" | sed -r "s!$pumlDir/(.+)\.preproc!preprocessed/\1\.preproc!")

    mkdir -p "$(dirname "$new")"

    mv "$old" "$new"
  done
}

test::generate-all() {
  pumlDir="${1:-puml}"
  echo "*** ${FUNCNAME[0]} $pumlDir ***"

  $PLANTUML_CMD -T"$DIAGRAM_FORMAT" -r "$TEST_ROOT/$pumlDir/**.puml"

  for old in "$TEST_ROOT/$pumlDir"/**/*."$DIAGRAM_FORMAT"; do
    new=$(echo "$old" | sed -r "s!$pumlDir/(.+)\.$DIAGRAM_FORMAT!diagrams/\1\.$DIAGRAM_FORMAT!")

    mkdir -p "$(dirname "$new")"

    if [ "$DIAGRAM_FORMAT" == "svg" ]; then
      xmllint --format "$old" > "$new"
      rm "$old"
    else
      mv "$old" "$new"
    fi
  done
}

test::check-sharness() {
  echo "*** ${FUNCNAME[0]} ***"
  "$TEST_ROOT/$LIB_DIR"/install-sharness.sh
}

test::check-deps() {
  which diff >/dev/null || (echo "Please install a diff tool!" && false)

  which magick >/dev/null || (echo "Please install ImageMagick!" && false)
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  cmd="${1:-all}"
  shift

  cd "$TEST_ROOT" || exit

  "test::$cmd" "$@"
fi
