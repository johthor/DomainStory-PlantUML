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

  magick compare -metric AE -fuzz 5% \
    "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_EXPECTATION$fileSuffix" \
    "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_ACTUAL$fileSuffix" \
    -highlight-color Magenta \
    magick "$SHARNESS_TEST_DIRECTORY/$subject"._COMPARISON.png
}

computeComposite() {
  subject="$1"
  fileSuffix="$2"

  magick composite \
    "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_EXPECTATION$fileSuffix" \
    "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_ACTUAL$fileSuffix" \
    -compose difference "$SHARNESS_TEST_DIRECTORY/$subject"._COMPOSITE.png
}

computeFlicker() {
  subject="$1"
  fileSuffix="$2"

  magick -delay 100 \
    "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_EXPECTATION$fileSuffix" \
    "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_ACTUAL$fileSuffix" \
    -loop 0 "$SHARNESS_TEST_DIRECTORY/$subject"._FLICKER.gif
}

computeStats() {
  subject="$1"
  fileSuffix="$2"

  magick \
    "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_EXPECTATION$fileSuffix" \
    "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_ACTUAL$fileSuffix" \
    -compose Difference -composite \
    -colorspace gray -verbose  info: |\
    sed -n '/statistics:/,/^  [^ ]/ p' 1>&2 \
    > "$SHARNESS_TEST_DIRECTORY/$subject"._STATS.txt
}

computeDiff() {
  subject="$1"
  fileSuffix="$2"

  values_small="^0\.[^ ]+ \([^e]+e-..\)"
  values_smaller="^[^e]+e-.. \([^e]+e-..\)"
  stat=$(magick compare -metric MAE \
    "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_EXPECTATION$fileSuffix" \
    "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_ACTUAL$fileSuffix" \
    null: 2>&1 | \
    grep -iv -e 'inkscape' -e '^$')

  if [[ "$stat" =~ $values_small ]]; then
    echo '0 (0)'
  elif [[ "$stat" =~ $values_smaller ]]; then
    echo '0 (0)'
  else
    echo "$stat"
  fi
}

compareImages() {
  subject="$1"
  fileSuffix="$2"

  if [ "$(computeDiff "$subject" "$fileSuffix")" != '0 (0)' ]; then
    computeComparison "$subject" "$fileSuffix"
    computeComposite "$subject" "$fileSuffix"
    computeFlicker "$subject" "$fileSuffix"
    computeStats "$subject" "$fileSuffix"

    echo "compare the files for $subject" 1>&2
    test 1 != 1
  fi
}

comparePreProcessed() {
  subject="$1"
  fileSuffix="$2"

  if ! diff -wB "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_EXPECTATION$fileSuffix" \
      "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_ACTUAL$fileSuffix"; then
    diff -wB "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_EXPECTATION$fileSuffix" \
      "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_ACTUAL$fileSuffix" \
      > "$SHARNESS_TEST_DIRECTORY/$subject"._DIFF.txt
    test 1 != 1
  fi
}
