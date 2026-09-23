# Getting Started

Register and resolve your first dependency with NerdzInject.

## Overview

NerdzInject centralizes object creation in one place. You register how a value
is produced, then resolve it wherever you need it without passing dependencies
through initializers by hand.

### Add the package

Add NerdzInject with Swift Package Manager, then import it where you register
or resolve dependencies.

```swift
import NerdzInject
```

### Register a dependency

Registration stores a factory closure. The closure runs the first time the value
is resolved, not when it is registered. Register against the inferred type, an
explicit type, or a string identifier.

```swift
// By inferred type.
NerdzInject.shared.register { AnalyticsClient() as Analytics }

// By explicit type, useful when a concrete type stands in for a protocol.
NerdzInject.shared.register(for: Analytics.self) { AnalyticsClient() }

// By string identifier, useful when several values share one type.
NerdzInject.shared.register(for: "primaryAnalytics") { AnalyticsClient() }
```

To register a value that already exists, use ``NerdzInject/registerObject(_:)``
and its overloads.

```swift
let session = URLSession.shared
NerdzInject.shared.registerObject(session)
```

### Cache with singletons

Pass `singleton: true` to cache the instance built on first resolution. Every
later resolution of the same key returns that cached instance.

```swift
NerdzInject.shared.register(singleton: true) { Database() }
```

### Resolve a dependency

Use ``NerdzInject/resolve()`` and its overloads for an optional result, or the
``NerdzInject/forceResolve()`` family when a value must exist.

```swift
// Optional resolution.
let analytics: Analytics? = NerdzInject.shared.resolve()

// Force resolution, which traps when nothing is registered.
let database: Database = NerdzInject.shared.forceResolve()
```

> Warning: The `forceResolve` family crashes when nothing is registered for the
> key. Reach for it only when a missing registration is a programmer error.

### Remove a dependency

Call ``NerdzInject/remove(by:)-(T.Type)`` to drop a registration, for example
when tearing down a scope in tests.

```swift
NerdzInject.shared.remove(by: Analytics.self)
```

## See Also

- <doc:UsingPropertyWrappers>
- ``NerdzInject``
