# Using property wrappers

Declare dependencies with ``Inject`` and ``ForceInject`` instead of resolving
them by hand.

## Overview

The property wrappers read from the same registry as
``NerdzInject/shared``. Reading a wrapped value resolves it lazily on every
access, so a property always reflects the current registration.

Pick a wrapper by how you want to handle a missing registration. ``Inject``
returns an optional and is safe when a value may be absent. ``ForceInject``
returns a non optional and traps when nothing is registered.

### Inject an optional dependency

``Inject`` resolves an optional value. It returns `nil` when nothing is
registered for the key.

```swift
final class ProfileViewModel {
    @Inject var analytics: Analytics?

    func track() {
        analytics?.log(event: "profile_opened")
    }
}
```

### Force inject a required dependency

``ForceInject`` resolves a non optional value. Use it when the dependency is
guaranteed to be registered before the property is read.

```swift
final class Router {
    @ForceInject var window: UIWindow
}
```

> Warning: Reading a ``ForceInject`` value crashes when nothing is registered
> for the key. Prefer ``Inject`` when a missing registration is possible.

### Choose the resolution key

Both wrappers resolve by the wrapped type by default. Pass an explicit type or a
string identifier to resolve a different key.

```swift
// By the wrapped type.
@Inject var analytics: Analytics?

// By an explicit type.
@Inject(Analytics.self) var analytics: AnalyticsClient?

// By a string identifier.
@Inject("primaryAnalytics") var analytics: Analytics?
```

### Register on assignment with allowRegister

By default the wrappers only read. Pass `allowRegister: true` to register the
assigned value into ``NerdzInject`` on write. When `allowRegister` is `false`,
assigning a new value does nothing.

```swift
final class Session {
    @Inject(allowRegister: true) var token: AuthToken?
}

let session = Session()
session.token = AuthToken(value: "abc") // Registers the token.

// Elsewhere the same token now resolves.
let token: AuthToken? = NerdzInject.shared.resolve()
```

## See Also

- <doc:GettingStarted>
- ``Inject``
- ``ForceInject``
