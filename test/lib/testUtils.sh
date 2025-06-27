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
  magick compare -metric AE -fuzz 5% \
    "$1" \
    "$2" \
    -highlight-color Magenta \
    magick "$3"
}

computeDiagramComparison() {
  subject="$1"
  fileSuffix="$2"

  computeComparison \
    "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_EXPECTATION$fileSuffix" \
    "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_ACTUAL$fileSuffix" \
    "$SHARNESS_TEST_DIRECTORY/$subject"._COMPARISON.png
}

computeComposite() {
  magick composite \
    "$1" \
    "$2" \
    -compose difference "$3"
}

computeDiagramComposite() {
  subject="$1"
  fileSuffix="$2"

  computeComposite \
    "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_EXPECTATION$fileSuffix" \
    "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_ACTUAL$fileSuffix" \
    "$SHARNESS_TEST_DIRECTORY/$subject"._COMPOSITE.png
}

computeFlicker() {
  magick -delay 100 \
    "$1" \
    "$2" \
    -loop 0 "$3"
}

computeDiagramFlicker() {
  subject="$1"
  fileSuffix="$2"

  computeFlicker \
    "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_EXPECTATION$fileSuffix" \
    "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_ACTUAL$fileSuffix" \
    "$SHARNESS_TEST_DIRECTORY/$subject"._FLICKER.gif
}

computeStats() {
  magick \
    "$1" \
    "$2" \
    -compose Difference -composite \
    -colorspace gray -verbose  info: |\
    sed -n '/statistics:/,/^  [^ ]/ p' 1>&2 \
    > "$3"
}

computeDiagramStats() {
  subject="$1"
  fileSuffix="$2"

  computeStats \
    "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_EXPECTATION$fileSuffix" \
    "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_ACTUAL$fileSuffix" \
    "$SHARNESS_TEST_DIRECTORY/$subject"._STATS.txt
}

computeDiff() {
  values_small="^0\.[^ ]+ \([^e]+e-..\)"
  values_smaller="^[^e]+e-.. \([^e]+e-..\)"
  stat=$(magick compare -metric MAE \
    "$1" \
    "$2" \
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

computeDiagramDiff() {
  subject="$1"
  fileSuffix="$2"

  computeDiff \
    "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_EXPECTATION$fileSuffix" \
    "$SHARNESS_TEST_DIRECTORY/$subject$SNAPSHOT_ACTUAL$fileSuffix"
}

compareImages() {
  subject="$1"
  fileSuffix="$2"

  if [ "$(computeDiagramDiff "$subject" "$fileSuffix")" != '0 (0)' ]; then
    computeDiagramComparison "$subject" "$fileSuffix"
    computeDiagramComposite "$subject" "$fileSuffix"
    computeDiagramFlicker "$subject" "$fileSuffix"
    computeDiagramStats "$subject" "$fileSuffix"

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
