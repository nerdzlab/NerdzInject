# Testing with NerdzInject

Isolate dependencies in unit tests so each test resolves from its own container.

## Overview

The ``Inject`` and ``ForceInject`` property wrappers resolve from
``NerdzInject/current``, an ambient container that defaults to
``NerdzInject/shared``. A wrapper captures ``NerdzInject/current`` when its
enclosing object is initialized, so an override applied while a type is built
inside a scope stays with that object even when it is used later. This gives each
test an isolated container with no global cleanup.

## Scoping dependencies with withDependencies

The primary entry point registers dependencies into a fresh container in the
first closure, then runs the test in the second. A type constructed inside the
operation closure captures that container.

```swift
import Testing
import NerdzInject

@Test func loadsProfile() {
    withDependencies {
        $0.registerObject(ProfileRepositorySpy(), for: ProfileRepository.self)
    } operation: {
        let sut = ProfileViewModel()
        sut.load()
    }
}
```

Because the container is fresh, a dependency the test forgot to register fails
loudly rather than resolving app wide state. There is an `async` overload for
asynchronous operations.

## Using the .nerdzContainer trait

Add the `NerdzInjectTesting` product to your test target to apply a Swift Testing
trait that binds a fresh container for the whole test body.

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

## Constructor injection

For explicit injection instead of property wrappers, ``NerdzInject`` conforms to
``DependencyResolver``. Take `any DependencyResolver` in an initializer,
defaulting to ``NerdzInject/shared``, and pass a test container in tests.

```swift
final class ProfileViewModel {
    private let repository: ProfileRepository

    init(resolver: DependencyResolver = .shared) {
        self.repository = resolver.forceResolve()
    }
}
```
