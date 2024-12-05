#!/usr/bin/env bash

TEST_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

TEST_FILES=$(find "$TEST_ROOT" -type f -name '*.test.sh' | sort)
LIB_DIR='lib'
SHARNESS_DIR='sharness'
AGGREGATE="$LIB_DIR/$SHARNESS_DIR/tools/aggregate-results.sh"

DIAGRAM_FORMAT='png'

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
  rm -f diagrams/**/*.COMPARISON.*
  rm -f diagrams/**/*.COMPOSITE.*
  rm -f diagrams/**/*.COMPOSITE_NORM.*
  rm -f diagrams/**/*.FLICKER.*
  rm -f preprocessed/**/*.actual.*
  rm -f preprocessed/**/*.DIFF.*
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
  test::generate-all "$@"
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
  echo "*** ${FUNCNAME[0]} ***"
  plantuml -preproc -r "$TEST_ROOT/puml/**/*.puml"

  for old in "$TEST_ROOT"/puml/**/*.preproc; do
    new=$(echo "$old" | sed -r "s!puml/(.+)\.preproc!preprocessed/\1\.preproc!")

    mkdir -p "$(dirname "$new")"

    mv "$old" "$new"
  done
}

test::generate-all() {
  echo "*** ${FUNCNAME[0]} ***"
  plantuml -T"$DIAGRAM_FORMAT" -r "$TEST_ROOT/puml/**/*.puml"

  for old in "$TEST_ROOT"/puml/**/*."$DIAGRAM_FORMAT"; do
    new=$(echo "$old" | sed -r "s!puml/(.+)\.$DIAGRAM_FORMAT!diagrams/\1\.$DIAGRAM_FORMAT!")

    mkdir -p "$(dirname "$new")"

    mv "$old" "$new"
  done
}

test::check-sharness() {
  echo "*** ${FUNCNAME[0]} ***"
  "$TEST_ROOT/$LIB_DIR"/install-sharness.sh
}

test::check-deps() {
  which diff >/dev/null || (echo "Please install a diff tool!" && false)

  which plantuml >/dev/null || (echo "Please install PlantUML!" && false)

  which magick >/dev/null || (echo "Please install ImageMagick!" && false)
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  cmd="${1:-all}"
  shift

  cd "$TEST_ROOT" || exit

  "test::$cmd" "$@"
fi
