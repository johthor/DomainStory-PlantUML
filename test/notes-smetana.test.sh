#!/usr/bin/env bash

shopt -s globstar

# shellcheck disable=SC2034
test_description='Compare snapshots to the newly generated files for notes generated with smetana'

. ./lib/testUtils.sh
. ./lib/sharness/sharness.sh

cd "$SHARNESS_TEST_DIRECTORY" || exit

for diagram in "$SHARNESS_TEST_DIRECTORY"/puml-smetana/notes/**/*.puml ; do
  fileNameWithoutExt=$(basename "$diagram" .puml)
  subPath=$(dirname "$diagram" | sed "s!$SHARNESS_TEST_DIRECTORY/puml-smetana/!!g")
  testSubject="$subPath/$fileNameWithoutExt"

  test_expect_success "diagram $testSubject.puml renders correctly" "
    ensureSnapshotExists diagrams/$testSubject .$DIAGRAM_FORMAT &&
    compareImages diagrams/$testSubject .$DIAGRAM_FORMAT
  "
done

test_done

# vi: set ft=sh.sharness :
