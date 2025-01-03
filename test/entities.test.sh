#!/usr/bin/env bash

# shellcheck disable=SC2034
test_description='Compare snapshots to the newly generated files for entities'

. ./lib/testUtils.sh
. ./lib/sharness/sharness.sh

cd "$SHARNESS_TEST_DIRECTORY" || exit

for diagram in "$SHARNESS_TEST_DIRECTORY"/puml/entities/*.puml ; do
  fileNameWithoutExt=$(basename "$diagram" .puml)
  subPath=$(dirname "$diagram" | sed "s!$SHARNESS_TEST_DIRECTORY/puml/!!g")
  testSubject="$subPath/$fileNameWithoutExt"


  if [[ ! "$testSubject" =~ .+IGNORE ]]; then
    test_expect_success "diagram $testSubject.puml renders correctly" "
      ensureSnapshotExists diagrams/$testSubject .$DIAGRAM_FORMAT &&
      compareImages diagrams/$testSubject .$DIAGRAM_FORMAT
    "
  fi

  test_expect_success "preprocessed $testSubject.puml matches snapshot" "
    ensureSnapshotExists preprocessed/$testSubject .preproc &&
    comparePreProcessed preprocessed/$testSubject .preproc
  "
done

test_done

# vi: set ft=sh.sharness :
