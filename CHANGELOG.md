# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - t.b.d.

### Changed

- Split library PUML into multiple source files ([#22](https://github.com/johthor/DomainStory-PlantUML/pull/22)), ([@johthor][gh-johthor])
- Add missing default styling from [Egon.io](https://egon.io/)
  ([#25](https://github.com/johthor/DomainStory-PlantUML/pull/25)), ([@johthor][gh-johthor])
 
### Added

- Add version table and mention breaking changes in README
  ([#24](https://github.com/johthor/DomainStory-PlantUML/pull/24)), ([@johthor][gh-johthor])
- Add automated snapshot test with [Sharness](https://felipec.github.io/sharness/)
  ([#25](https://github.com/johthor/DomainStory-PlantUML/pull/25)), ([@johthor][gh-johthor])
- Add new step label position `prefix`
  ([#25](https://github.com/johthor/DomainStory-PlantUML/pull/25)), ([@johthor][gh-johthor])

### Fixed

- Fix auto-incrementing step counter for parallel steps
  ([#25](https://github.com/johthor/DomainStory-PlantUML/pull/25)), ([@johthor][gh-johthor])
- Fix handling of optional activity parameters (`post` and `target`)
  ([#25](https://github.com/johthor/DomainStory-PlantUML/pull/25)), ([@johthor][gh-johthor])
- Fix styling of boundary titles if combined with a boundary note
  ([#25](https://github.com/johthor/DomainStory-PlantUML/pull/25)), ([@johthor][gh-johthor])

## Delta [0.4.0] - 2024-11-30

The library now supports the build-in PlantUML themes
and won't set any colors if a theme declaration is discovered.
This leads to a complete rewrite of the styling declarations
and extending the concept for multi-level declarations.

### Changed

- **Breaking:** Rewrite the styling declaration concept ([#9](https://github.com/johthor/DomainStory-PlantUML/pull/9)), ([@johthor][gh-johthor])
- **Breaking:** Switch activity direction indicator from suffix to prefix ([@johthor][gh-johthor])

### Added

- Add support for PlantUML themes and dark-mode ([#9](https://github.com/johthor/DomainStory-PlantUML/pull/9)), ([@johthor][gh-johthor])
- Add style tags to actors, objects and boundaries ([#9](https://github.com/johthor/DomainStory-PlantUML/pull/9)), ([@johthor][gh-johthor])
- Add new icon styles for person actors ([#4](https://github.com/johthor/DomainStory-PlantUML/issues/4)), ([@johthor][gh-johthor])


## Charlie's Quality [0.3.1] - 2024-10-29

Some quality of life improvements.

### Changed

- Allow step numbers to be hidden ([#7](https://github.com/johthor/DomainStory-PlantUML/pull/7)) ([@Potherca](https://github.com/Potherca) and [@stephenwithav](https://github.com/stephenwithav))
- Allow dynamic creation for activity targets too ([@stephenwithav](https://github.com/stephenwithav))
- Extract advanced features into an extra README section ([@johthor][gh-johthor])

### Added

- Create this changelog ([@johthor][gh-johthor])
- Introduce explicit story layout definition ([#3](https://github.com/johthor/DomainStory-PlantUML/pull/3)) ([@johthor][gh-johthor])
- Allow notes to be applied to boundaries too ([#3](https://github.com/johthor/DomainStory-PlantUML/pull/3)) ([@kirchsth](https://github.com/kirchsth) and [@johthor][gh-johthor])
- Introduce new ways to specify the direction of activities ([@johthor][gh-johthor])


## Charlie [0.3] - 2022-04-18

Enable styling declarations.

### Changed

- Allow styling definitions to be defined before including the library ([@johthor][gh-johthor])


## Bravo [0.2] - 2022-04-18

Complete rework of all macros inspired by the work of ([@dirx](https://github.com/dirx))

### Changed

- Switch `!definelong` and `!define` to `!procedure` and `!function` preprocessor directives ([@johthor][gh-johthor])
- Improve control of the activity layout ([@johthor][gh-johthor])
- Rewrite portions of the README ([@johthor][gh-johthor])

### Added

- Add dynamic creation of work objects ([@johthor][gh-johthor])
- Apply notes to actors and work objects too ([@johthor][gh-johthor])
- Apply notes in a specific orientation ([@johthor][gh-johthor])
- Allow step numbers to auto increment ([@johthor][gh-johthor])
- Extend README with descriptions of new or extended features ([@johthor][gh-johthor])


### Fixed

- Fix activity directions ([@johthor][gh-johthor])


## Alpha [0.1] - 2021-05-05

:seedling: _The first ever release._

### Added

- Add initial macro definitions ([@johthor][gh-johthor])
- Add initial README including multiple samples ([@johthor][gh-johthor])

[Unreleased]: https://github.com/johthor/DomainStory-PlantUML/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/johthor/DomainStory-PlantUML/releases/tag/v0.4.0
[0.3.1]: https://github.com/johthor/DomainStory-PlantUML/releases/tag/v0.3.1
[0.3]: https://github.com/johthor/DomainStory-PlantUML/releases/tag/v0.3
[0.2]: https://github.com/johthor/DomainStory-PlantUML/releases/tag/v0.2
[0.1]: https://github.com/johthor/DomainStory-PlantUML/releases/tag/v0.1

[gh-johthor]: https://github.com/johthor

[//]: # (Types of changes)
[//]: # (Added: for new features.)
[//]: # (Changed: for changes in existing functionality.)
[//]: # (Deprecated: for soon-to-be removed features.)
[//]: # (Removed: for now removed features.)
[//]: # (Fixed: for any bug fixes.)
[//]: # (Security: in case of vulnerabilities.)
