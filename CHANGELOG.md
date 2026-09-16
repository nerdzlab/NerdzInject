# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0]

Breaking release: CocoaPods support is removed (Swift Package Manager only), the minimum platforms are raised, and building the tests now requires Swift 5.9+ (Xcode 15+).

### Breaking changes

- CocoaPods support removed. NerdzInject is distributed through Swift Package Manager only.
- Minimum platforms raised to iOS 16, macOS 13, tvOS 16, watchOS 9, and visionOS 1.
- The core protocol and types now require Swift 5.9+ (Xcode 15+) to build the tests.

### Added

- Swift Testing test suite with high coverage.
- DocC documentation.
- GitHub Actions CI (Linux) that runs build, test, and a strict-concurrency build.
- Full Apple platform declarations in `Package.swift`.

### Changed

- `swift-tools-version` raised to 5.9.
- `NerdzInject` is now thread-safe and (checked) `Sendable`, backed by an internal `NSLock`-based `LockedState`.
- `Inject` and `ForceInject` property wrappers changed from `class` to `struct`.

### Fixed

- The `singleton:` parameter was previously dropped for type-based and closure-based registration, so lazy-singleton caching never took effect for those overloads. It now works for all registration forms.

### Behavior change

- Type-based and closure-based registration with `singleton: true` now caches the resolved instance after the first resolve, as documented, instead of re-running the factory on every resolve.

[2.0.0]: https://github.com/nerdzlab/NerdzInject/releases/tag/2.0.0
