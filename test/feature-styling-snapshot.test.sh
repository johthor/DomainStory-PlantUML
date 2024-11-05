#!/bin/sh

# shellcheck disable=SC2034
test_description='Compare snapshots to the newly generated files for styling'

. ./lib/testUtils.sh
. ./lib/sharness/sharness.sh

cd "$SHARNESS_TEST_DIRECTORY" || exit

for diagram in "$SHARNESS_TEST_DIRECTORY"/puml/styling/*.puml ; do
  fileNameWithoutExt=$(basename "$diagram" .puml)
  subPath=$(dirname "$diagram" | sed "s!$SHARNESS_TEST_DIRECTORY/puml/!!g")
  testSubject="$subPath/$fileNameWithoutExt"

  test_expect_success "diagram $testSubject.puml renders correctly" "
    ensureSnapshotExists diagrams/$testSubject .svg &&
    compareImages diagrams/$testSubject .svg
  "

  test_expect_success "preprocessed $testSubject.puml matches snapshot" "
    ensureSnapshotExists preprocessed/$testSubject .preproc &&
    diff preprocessed/$testSubject.expected.preproc preprocessed/$testSubject.actual.preproc > preprocessed/$testSubject.DIFF.preproc "
done

test_done

# vi: set ft=sh.sharness :
