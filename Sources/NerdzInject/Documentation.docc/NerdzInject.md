# ``NerdzInject``

A small, pure Foundation dependency injection container for Apple platforms.

## Overview

NerdzInject registers factories and instances in a single shared registry and
resolves them on demand. It keeps a synchronous API, so resolution never
requires `await`, while the registry stays safe to use across concurrency
domains.

There are two ways to consume a dependency. Resolve it directly through
``NerdzInject/shared``, or declare it with the ``Inject`` and ``ForceInject``
property wrappers, which resolve against that same shared registry.

```swift
// Register once, for example at app launch.
NerdzInject.shared.register(singleton: true) { NetworkService() as Networking }

// Resolve where it is needed.
let service: Networking? = NerdzInject.shared.resolve()

// Or declare it with a property wrapper.
@Inject var networking: Networking?
```

Registration accepts three kinds of keys: the inferred type, an explicit type,
or a string identifier. Each `register` factory can be marked as a `singleton`,
which caches the instance built on first resolution and reuses it afterwards.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:UsingPropertyWrappers>
- ``NerdzInject/shared``

### Registering

- ``NerdzInject/registerObject(_:)``
- ``NerdzInject/registerObject(_:for:)-(_,V.Type)``
- ``NerdzInject/registerObject(_:for:)-(_,String)``
- ``NerdzInject/register(singleton:closure:)``
- ``NerdzInject/register(singleton:for:closure:)-(_,V.Type,_)``
- ``NerdzInject/register(singleton:for:closure:)-(_,String,_)``

### Resolving

- ``NerdzInject/resolve()``
- ``NerdzInject/resolve(by:)-(V.Type)``
- ``NerdzInject/resolve(by:)-(String)``
- ``NerdzInject/forceResolve()``
- ``NerdzInject/forceResolve(by:)-(V.Type)``
- ``NerdzInject/forceResolve(by:)-(String)``

### Property Wrappers

- ``Inject``
- ``ForceInject``

### Removing

- ``NerdzInject/remove(by:)-(String)``
- ``NerdzInject/remove(by:)-(T.Type)``
