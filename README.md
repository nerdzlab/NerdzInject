# NerdzInject

NerdzInject is a small, pure Foundation library that makes it easy to use the Dependency Injection pattern in your Swift project. The shared container is thread-safe and `Sendable`, so you can register and resolve dependencies from any thread.

[![Documentation](https://img.shields.io/badge/docs-GitHub%20Pages-blue)](https://nerdzlab.github.io/NerdzInject/documentation/nerdzinject/)

## Requirements

- Swift 5.9+ / Xcode 15+
- iOS 16+, macOS 13+, tvOS 16+, watchOS 9+, visionOS 1+

## Installation

NerdzInject is distributed through the [Swift Package Manager](https://swift.org/package-manager/).

Add it to the `dependencies` array in your `Package.swift`:

```swift
.package(url: "https://github.com/nerdzlab/NerdzInject", from: "2.0.0")
```

Then add `NerdzInject` to your target's dependencies:

```swift
.product(name: "NerdzInject", package: "NerdzInject")
```

In Xcode, use File, Add Package Dependencies and paste `https://github.com/nerdzlab/NerdzInject`.

## Quick start

Register a dependency once (for example during app start up), then resolve it wherever you need it.

```swift
import NerdzInject

// Register
NerdzInject.shared.registerObject(MyService())

// Resolve
let service: MyService? = NerdzInject.shared.resolve()

// Or resolve through a property wrapper
@Inject var injectedService: MyService?
```

## Registering

You register either a concrete object or a closure that produces a value. Everything goes through the shared container, `NerdzInject.shared`.

### Registering objects

Register an instance to be resolved later by its own type:

```swift
NerdzInject.shared.registerObject(MyService())
```

Register an instance to be resolved by a base type. This is useful when you want a subclass (or a concrete type conforming to a protocol) to be returned for requests of the base type:

```swift
NerdzInject.shared.registerObject(MyService(), for: ServiceProtocol.self)
```

Register an instance to be resolved by a custom string identifier:

```swift
NerdzInject.shared.registerObject(MyService(), for: "my_custom_identifier")
```

### Registering closures

You can register a closure that produces the value. This enables factory style creation or lazy initialization. The closure runs when the value is first resolved.

The `singleton` parameter controls caching. When `singleton: true`, the resolved instance is cached after the first resolve, so every later resolve returns the same instance (a lazy singleton). When `singleton: false` (the default), the factory closure runs on every resolve and produces a new instance each time.

```swift
// Resolved by inferred type, new instance every resolve
NerdzInject.shared.register {
    MyService()
}

// Resolved by provided type
NerdzInject.shared.register(for: ServiceProtocol.self) {
    MyService()
}

// Resolved by identifier, cached after the first resolve (lazy singleton)
NerdzInject.shared.register(singleton: true, for: "custom_identifier") {
    MyService()
}
```

## Resolving

`resolve` returns an optional and mirrors the ways you registered: by inferred type, by a provided type, or by identifier.

```swift
let byInferredType: MyService? = NerdzInject.shared.resolve()
let byProvidedType: ServiceProtocol? = NerdzInject.shared.resolve(by: MyService.self)
let byIdentifier: MyService? = NerdzInject.shared.resolve(by: "my_custom_identifier")
```

### forceResolve

When you are certain a dependency is registered, `forceResolve` returns a non optional value. It traps at runtime if nothing is registered, so reach for it only when a missing dependency is a programmer error.

```swift
let byInferredType: MyService = NerdzInject.shared.forceResolve()
let byProvidedType: ServiceProtocol = NerdzInject.shared.forceResolve(by: MyService.self)
let byIdentifier: MyService = NerdzInject.shared.forceResolve(by: "my_custom_identifier")
```

## Property wrappers

Property wrappers let you resolve dependencies declaratively, without calling the container by hand.

### @Inject

`@Inject` resolves an optional value. It supports the same lookups as `resolve`: by inferred type, by a provided type, or by identifier.

```swift
@Inject var byInferredType: MyService?
@Inject(MyService.self) var byProvidedType: ServiceProtocol?
@Inject("my_custom_identifier") var byIdentifier: MyService?
```

### @ForceInject

`@ForceInject` resolves a non optional value, mirroring `forceResolve`. It traps at runtime when nothing is registered.

```swift
@ForceInject var byInferredType: MyService
@ForceInject(MyService.self) var byProvidedType: ServiceProtocol
@ForceInject("my_custom_identifier") var byIdentifier: MyService
```

### allowRegister

Both wrappers accept an `allowRegister` flag (default `false`). When it is `true`, assigning a new value to the wrapped property registers that value back into the container under the same identifier. When it is `false`, assignments are ignored.

```swift
@Inject(allowRegister: true) var service: MyService?

// Because allowRegister is true, this registers the new instance into the container
service = MyService()
```

## Testing

The property wrappers resolve from `NerdzInject.current`, an ambient container that defaults to `NerdzInject.shared`. A wrapper captures `current` when its enclosing object is initialized, so you can give a test its own isolated container and an override sticks to any object built inside the scope. This keeps tests isolated from each other and from app wide registrations, with no manual cleanup.

The primary API is `withDependencies`. The first closure registers dependencies into a fresh container, and the second runs your test against it.

```swift
import Testing
import NerdzInject

@Test func loadsProfile() {
    withDependencies {
        $0.registerObject(ProfileRepositorySpy(), for: ProfileRepository.self)
    } operation: {
        let sut = ProfileViewModel()   // captures the fresh container
        sut.load()
    }
}
```

If you prefer not to wrap the whole body, add the `NerdzInjectTesting` product to your test target and apply the `.nerdzContainer` trait. Each test then runs with its own fresh container.

```swift
import Testing
import NerdzInject
import NerdzInjectTesting

@Test(.nerdzContainer) func loadsProfile() {
    NerdzInject.current.registerObject(ProfileRepositorySpy(), for: ProfileRepository.self)
    let sut = ProfileViewModel()
    sut.load()
}
```

For teams that prefer explicit constructor injection over property wrappers, `NerdzInject` conforms to `DependencyResolver`. Take `any DependencyResolver` in an initializer (defaulting to `.shared`) and pass a test container in tests.

```swift
final class ProfileViewModel {
    private let repository: ProfileRepository

    init(resolver: DependencyResolver = .shared) {
        self.repository = resolver.forceResolve()
    }
}

// In a test
let container = NerdzInject()
container.registerObject(ProfileRepositorySpy(), for: ProfileRepository.self)
let sut = ProfileViewModel(resolver: container)
```

## Removing

You can remove a registered object or closure by identifier or by type. The call returns `true` when something was removed.

```swift
let removedByIdentifier = NerdzInject.shared.remove(by: "my_custom_identifier")
let removedByType = NerdzInject.shared.remove(by: MyService.self)
```

## License

This code is distributed under the MIT license. See the `LICENSE` file for more info.
