SNAPSHOT_EXPECTATION='.expected'
SNAPSHOT_ACTUAL='.actual'

ensureSnapshotExists() {
  subject="$1"
  fileSuffix="$2"

  if [ ! -f "$subject$SNAPSHOT_EXPECTATION$fileSuffix" ]; then
    cp "$subject$fileSuffix" "$subject$SNAPSHOT_EXPECTATION$fileSuffix"
  fi

  mv "$subject$fileSuffix" "$subject$SNAPSHOT_ACTUAL$fileSuffix"
}

computeComparison() {
  subject="$1"
  fileSuffix="$2"
  magick compare -metric AE -fuzz 10% \
    "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_EXPECTATION$fileSuffix" \
    "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_ACTUAL$fileSuffix" \
    "$SHARNESS_TEST_DIRECTORY/$subject".COMPARISON.png
}

computeComposite() {
  subject="$1"
  subject="$1"
  fileSuffix="$2"
  magick composite \
    "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_EXPECTATION$fileSuffix" \
    "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_ACTUAL$fileSuffix" \
    -compose difference "$SHARNESS_TEST_DIRECTORY/$subject".COMPOSITE.png
}

computeStats() {
  subject="$1"
  subject="$1"
  fileSuffix="$2"
  magick \
    "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_EXPECTATION$fileSuffix" \
    "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_ACTUAL$fileSuffix" \
    -compose Difference -composite \
    -colorspace gray -verbose  info: |\
    sed -n '/statistics:/,/^  [^ ]/ p' 1>&2
}

computeDiff() {
  subject="$1"
  fileSuffix="$2"
  magick compare -metric MAE \
    "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_EXPECTATION$fileSuffix" \
    "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_ACTUAL$fileSuffix" \
    null: 2>&1
}

compareImages() {
  subject="$1"
  fileSuffix="$2"

  if [ "$(computeDiff "$subject" "$fileSuffix")" != '0 (0)' ]; then
    computeComparison "$subject" "$fileSuffix"
    computeComposite "$subject" "$fileSuffix"
    computeStats "$subject" "$fileSuffix"

    echo "compare the files for $subject" 1>&2
    test 1 != 1
  fi
}
