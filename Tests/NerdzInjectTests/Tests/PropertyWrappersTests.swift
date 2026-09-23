import Testing
@testable import NerdzInject

// MARK: - Marker types

private final class WrapperDependency {
    let tag: String
    init(tag: String) { self.tag = tag }
}

// Dedicated marker types for type-based wrapper tests so registrations keyed by
// the type name never collide with other tests running in parallel.
private final class InjectByTypeDependency {}
private final class InjectByGenericDependency {}
private final class ForceInjectByTypeDependency {}
private final class ForceInjectByGenericDependency {}

// MARK: - Test data

private enum TestData {
    static func makeDependency(tag: String = "wrapper.dependency") -> WrapperDependency {
        WrapperDependency(tag: tag)
    }
}

// MARK: - Suites

@Suite("Property Wrappers Tests")
struct PropertyWrappersTests {

    private var container: NerdzInject { .shared }

    @Suite("Inject")
    struct InjectTests {

        private var container: NerdzInject { .shared }

        @Test func testWhenValueRegisteredShouldResolveThroughWrapper() {
            // Arrange
            let identifier = "inject.get"
            let dependency = TestData.makeDependency()
            defer { container.remove(by: identifier) }
            container.registerObject(dependency, for: identifier)

            // Act
            let injected = Inject<WrapperDependency>(identifier)
            let resolved = injected.wrappedValue

            // Assert
            #expect(resolved === dependency)
        }

        @Test func testWhenAllowRegisterTrueShouldRegisterOnSet() {
            // Arrange
            let identifier = "inject.set.allowed"
            let dependency = TestData.makeDependency()
            defer { container.remove(by: identifier) }
            let injected = Inject<WrapperDependency>(identifier, allowRegister: true)

            // Act
            injected.wrappedValue = dependency
            let resolved: WrapperDependency? = container.resolve(by: identifier)

            // Assert
            #expect(resolved === dependency)
        }

        @Test func testWhenAllowRegisterFalseShouldNotRegisterOnSet() {
            // Arrange
            let identifier = "inject.set.disallowed"
            let dependency = TestData.makeDependency()
            defer { container.remove(by: identifier) }
            let injected = Inject<WrapperDependency>(identifier, allowRegister: false)

            // Act
            injected.wrappedValue = dependency
            let resolved: WrapperDependency? = container.resolve(by: identifier)

            // Assert
            #expect(resolved == nil)
        }

        @Test func testWhenInitWithTypeShouldResolveByThatType() {
            // Arrange
            let dependency = InjectByTypeDependency()
            defer { container.remove(by: InjectByTypeDependency.self) }
            container.registerObject(dependency, for: InjectByTypeDependency.self)

            // Act
            let injected = Inject<InjectByTypeDependency>(InjectByTypeDependency.self)
            let resolved = injected.wrappedValue

            // Assert
            #expect(resolved === dependency)
        }

        @Test func testWhenInitWithGenericTypeShouldResolveByThatType() {
            // Arrange
            let dependency = InjectByGenericDependency()
            defer { container.remove(by: InjectByGenericDependency.self) }
            container.registerObject(dependency)

            // Act
            let injected = Inject<InjectByGenericDependency>()
            let resolved = injected.wrappedValue

            // Assert
            #expect(resolved === dependency)
        }
    }

    @Suite("ForceInject")
    struct ForceInjectTests {

        private var container: NerdzInject { .shared }

        @Test func testWhenValueRegisteredShouldForceResolveThroughWrapper() {
            // Arrange
            let identifier = "force.inject.get"
            let dependency = TestData.makeDependency()
            defer { container.remove(by: identifier) }
            container.registerObject(dependency, for: identifier)

            // Act
            let injected = ForceInject<WrapperDependency>(identifier)
            let resolved = injected.wrappedValue

            // Assert
            #expect(resolved === dependency)
        }

        @Test func testWhenAllowRegisterTrueShouldRegisterOnSet() {
            // Arrange
            let identifier = "force.inject.set.allowed"
            let dependency = TestData.makeDependency()
            defer { container.remove(by: identifier) }
            let injected = ForceInject<WrapperDependency>(identifier, allowRegister: true)

            // Act
            injected.wrappedValue = dependency
            let resolved: WrapperDependency? = container.resolve(by: identifier)

            // Assert
            #expect(resolved === dependency)
        }

        @Test func testWhenAllowRegisterFalseShouldNotRegisterOnSet() {
            // Arrange
            let identifier = "force.inject.set.disallowed"
            let dependency = TestData.makeDependency()
            defer { container.remove(by: identifier) }
            let injected = ForceInject<WrapperDependency>(identifier, allowRegister: false)

            // Act
            injected.wrappedValue = dependency
            let resolved: WrapperDependency? = container.resolve(by: identifier)

            // Assert
            #expect(resolved == nil)
        }

        @Test func testWhenInitWithTypeShouldForceResolveByThatType() {
            // Arrange
            let dependency = ForceInjectByTypeDependency()
            defer { container.remove(by: ForceInjectByTypeDependency.self) }
            container.registerObject(dependency, for: ForceInjectByTypeDependency.self)

            // Act
            let injected = ForceInject<ForceInjectByTypeDependency>(ForceInjectByTypeDependency.self)
            let resolved = injected.wrappedValue

            // Assert
            #expect(resolved === dependency)
        }

        @Test func testWhenInitWithGenericTypeShouldForceResolveByThatType() {
            // Arrange
            let dependency = ForceInjectByGenericDependency()
            defer { container.remove(by: ForceInjectByGenericDependency.self) }
            container.registerObject(dependency)

            // Act
            let injected = ForceInject<ForceInjectByGenericDependency>()
            let resolved = injected.wrappedValue

            // Assert
            #expect(resolved === dependency)
        }
    }
}
