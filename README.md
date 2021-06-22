# NerdzInject

NerdzInject library allow to easily use Dependency Injection patter in your Swift project.

## [Documentation](https://nerdzinject.web.app)

## Example

You will need to register your instances or closures in `NerdzInject` class.

### Registering instance

```swift
NerdzInject.shared.registerObject(_ object: myInstance)
```

### Registering instance with specifying class type

This method should be used when you want to registed some inherited class instance for use when somebody will be resolving base class

```swift
NerdzInject.shared.registerObject(_ object: inheritedClassInstance, for: BaseClass.self)
```

### Registering instance with specifying identifier

This method should be used when you want to registed some instance for use when somebody will be resolving by identifier

```swift
NerdzInject.shared.registerObject(_ object: myInstance, for: "my_custom_identifier")
```

### Registering with closure

You can also register a closures that should return a value. This will allow you to implement factory or lazy initialization. 
Use `singleton` parameter to define if this needs to be a factory or lazy initialization. By default value is `false`.

```swift
NerdzInject.shared.register {
    MyClassCreatedInFacvtory()
}

NerdzInject.shared.register(for: MyClass.self) {
    MyClassCreatedInFacvtory()
}

NerdzInject.shared.register(singleton: true, for: "custom_identifier") {
    MyClassCreatedInFacvtory()
}

```

### Resoving instances

You can resove an instance in a similar ways like registering: by identifier, by specifying class, by instance type.

```swift
let resolvedByInstanceType: MyType? = NerdzInject.shared.resolve()
let resolvedByProvidedType: NyBaseType? = NerdzInject.shared.resolve(by: MyType.self)
let resolvedByIdentifier: MyType? = NerdzInject.shared.resolve(by: "identifier")
}
```
Or resolving by property wrapper `Inject` in similar ways.

```swift
@Inject var resolvedByInstanceType: MyType?
@Inject(MyType.self) var resolvedByProvidedType: MyBaseType?
@Inject("identifier") var resolvedByIdentifier: MyType?
```

### ForceInject

You can use `ForceInject` property wrapper to avoid optional types on resolving. From previous example we will get:

```swift
@ForceInject var resolvedByInstanceType: MyType
@ForceInject(MyType.self) var resolvedByProvidedType: MyBaseType
@ForceInject("identifier") var resolvedByIdentifier: MyType
```

### Removing instances

You can also remove registered instances.closures by using `remove` method

```swift
let success = NerdzInject.shared.remove(by: identifier)
NerdzInject.shared.remove(by: MyClass.self)
```

## Installation Swift Package Manager

To add NerdzInject to a [Swift Package Manager](https://swift.org/package-manager/) based project, add:

```swift
.package(url: "https://github.com/nerdzlab/NerdzInject")
```

## License

This code is distributed under the MIT license. See the `LICENSE` file for more info.
