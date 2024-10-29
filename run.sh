#!/bin/bash

DS_PUML_URL='https://github.com/johthor/DomainStory-PlantUML'

PROJECT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# Convert all samples into assets
run::convertAssets() {
  for s in samples/*.puml; do
    echo Converting $s
    plantuml -Tsvg -o $PROJECT_ROOT/assets $s
  done
}

# Extract Table of Contents from Readme
run::extractTOC() {
  grep -e ^\## README.md | grep -v 'Table of Contents'
}

# Bake the next release version
run::bakeRelease() {
  version="$1"
  versionName="${2:-'Next Version'}"
  pathToStdLib="${3:-"$PROJECT_ROOT/../plantuml-stdlib"}"
  domainStoryDir="$pathToStdLib/DomainStory"

  echo "Next Release $versionName with version $version will be baked into $domainStoryDir"

  # Update DomainStoryVersion
  sed -i .bak -E "s/' DomainStory-PlantUML, version .+/' DomainStory-PlantUML, version $version/" "$PROJECT_ROOT/domainStory.puml"
  sed -i .bak -E "s/\!global \\\$DomainStoryVersion  =  \".+\"/\!global \\\$DomainStoryVersion  =  \"$version\"/" "$PROJECT_ROOT/domainStory.puml"

  # Update Changelog
  sed -i .bak -E "s/## \[Unreleased\] - t.b.d./## \[Unreleased\] - t.b.d.\n\n\n## $versionName \[$version\] - $(date +'%Y-%m-%d')/" "$PROJECT_ROOT/CHANGELOG.md"
  sed -i .bak -E "s/\[Unreleased\]: https:\/\/github.com\/johthor\/DomainStory-PlantUML\/compare\/v.+\.\.\.HEAD/\
\[Unreleased\]: https:\/\/github.com\/johthor\/DomainStory-PlantUML\/compare\/v$version\.\.\.HEAD\n\
\[$version\]: https:\/\/github.com\/johthor\/DomainStory-PlantUML\/releases\/tag\/v$version/" "$PROJECT_ROOT/CHANGELOG.md"


  # Update INFO file
  {
    echo "VERSION=$version"
    echo "SOURCE=$DS_PUML_URL"
  } > "$domainStoryDir/INFO"

  # Copy over relevant PUML files
  cp "$PROJECT_ROOT/domainStory.puml" "$domainStoryDir"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && "run::$@"
