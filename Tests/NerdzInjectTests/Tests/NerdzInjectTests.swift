import Testing
import Dispatch
import Foundation
@testable import NerdzInject

// MARK: - Marker types

// Each type-based test uses a dedicated marker type so that registrations keyed
// by the type name never collide with other tests running in parallel.

private final class RegisteredByInstance {}
private protocol RegisterForTypeParent: AnyObject {}
private final class RegisterForTypeChild: RegisterForTypeParent {}

private final class ClosureInferredType {
    let tag: String
    init(tag: String) { self.tag = tag }
}
private protocol ClosureForTypeParent: AnyObject {}
private final class ClosureForTypeChild: ClosureForTypeParent {}

private final class ResolveInferredType {}
private protocol ResolveByTypeParent: AnyObject {}
private final class ResolveByTypeChild: ResolveByTypeParent {}

private final class ForceResolveByType {}
private final class RemoveByType {}

private final class SingletonTypeBased {}
private final class SingletonClosureBased {}
private final class NonSingletonType {}

/// Reusable identity-bearing instance for identifier-keyed tests.
private final class Instance {
    let tag: String
    init(tag: String) { self.tag = tag }
}

// MARK: - Test data

private enum TestData {
    static func makeInstance(tag: String = "instance") -> Instance {
        Instance(tag: tag)
    }
}

// MARK: - Suites

@Suite("NerdzInject Tests")
struct NerdzInjectTests {

    private var container: NerdzInject { .shared }

    @Suite("Register Object")
    struct RegisterObjectTests {

        private var container: NerdzInject { .shared }

        @Test func testWhenRegisterObjectByInstanceTypeShouldResolveBySameType() {
            // Arrange
            let object = RegisteredByInstance()
            defer { container.remove(by: RegisteredByInstance.self) }

            // Act
            container.registerObject(object)
            let resolved: RegisteredByInstance? = container.resolve()

            // Assert
            #expect(resolved === object)
        }

        @Test func testWhenRegisterObjectForTypeShouldResolveByThatType() {
            // Arrange
            let object = RegisterForTypeChild()
            defer { container.remove(by: RegisterForTypeParent.self) }

            // Act
            container.registerObject(object, for: RegisterForTypeParent.self)
            let resolved: RegisterForTypeParent? = container.resolve(by: RegisterForTypeParent.self)

            // Assert
            #expect(resolved === object)
        }

        @Test func testWhenRegisterObjectForIdentifierShouldResolveByIdentifier() {
            // Arrange
            let identifier = "register.object.identifier"
            let object = TestData.makeInstance()
            defer { container.remove(by: identifier) }

            // Act
            container.registerObject(object, for: identifier)
            let resolved: Instance? = container.resolve(by: identifier)

            // Assert
            #expect(resolved === object)
        }
    }

    @Suite("Register Closure")
    struct RegisterClosureTests {

        private var container: NerdzInject { .shared }

        @Test func testWhenRegisterClosureByInferredTypeShouldResolve() {
            // Arrange
            let expectedTag = "closure.inferred"
            defer { container.remove(by: ClosureInferredType.self) }

            // Act
            container.register { ClosureInferredType(tag: expectedTag) }
            let resolved: ClosureInferredType? = container.resolve()

            // Assert
            #expect(resolved?.tag == expectedTag)
        }

        @Test func testWhenRegisterClosureForTypeShouldResolveByThatType() {
            // Arrange
            let object = ClosureForTypeChild()
            defer { container.remove(by: ClosureForTypeParent.self) }

            // Act
            container.register(for: ClosureForTypeParent.self) { object }
            let resolved: ClosureForTypeParent? = container.resolve(by: ClosureForTypeParent.self)

            // Assert
            #expect(resolved === object)
        }

        @Test func testWhenRegisterClosureForIdentifierShouldResolve() {
            // Arrange
            let identifier = "register.closure.identifier"
            let object = TestData.makeInstance()
            defer { container.remove(by: identifier) }

            // Act
            container.register(for: identifier) { object }
            let resolved: Instance? = container.resolve(by: identifier)

            // Assert
            #expect(resolved === object)
        }
    }

    @Suite("Resolve")
    struct ResolveTests {

        private var container: NerdzInject { .shared }

        @Test func testWhenResolveByInferredTypeShouldReturnRegistered() {
            // Arrange
            let object = ResolveInferredType()
            defer { container.remove(by: ResolveInferredType.self) }
            container.registerObject(object)

            // Act
            let resolved: ResolveInferredType? = container.resolve()

            // Assert
            #expect(resolved === object)
        }

        @Test func testWhenResolveByProvidedTypeShouldReturnRegistered() {
            // Arrange
            let object = ResolveByTypeChild()
            defer { container.remove(by: ResolveByTypeParent.self) }
            container.registerObject(object, for: ResolveByTypeParent.self)

            // Act
            let resolved: ResolveByTypeParent? = container.resolve(by: ResolveByTypeParent.self)

            // Assert
            #expect(resolved === object)
        }

        @Test func testWhenResolveByIdentifierShouldReturnRegistered() {
            // Arrange
            let identifier = "resolve.identifier"
            let object = TestData.makeInstance()
            defer { container.remove(by: identifier) }
            container.registerObject(object, for: identifier)

            // Act
            let resolved: Instance? = container.resolve(by: identifier)

            // Assert
            #expect(resolved === object)
        }

        @Test func testWhenResolveMissingIdentifierShouldReturnNil() {
            // Arrange
            let identifier = "resolve.missing.identifier"

            // Act
            let resolved: Instance? = container.resolve(by: identifier)

            // Assert
            #expect(resolved == nil)
        }
    }

    @Suite("Force Resolve")
    struct ForceResolveTests {

        private var container: NerdzInject { .shared }

        @Test func testWhenForceResolveByIdentifierShouldReturnRegistered() {
            // Arrange
            let identifier = "force.resolve.identifier"
            let object = TestData.makeInstance()
            defer { container.remove(by: identifier) }
            container.registerObject(object, for: identifier)

            // Act
            let resolved: Instance = container.forceResolve(by: identifier)

            // Assert
            #expect(resolved === object)
        }

        @Test func testWhenForceResolveByTypeShouldReturnRegistered() {
            // Arrange
            let object = ForceResolveByType()
            defer { container.remove(by: ForceResolveByType.self) }
            container.registerObject(object)

            // Act
            let resolved: ForceResolveByType = container.forceResolve()

            // Assert
            #expect(resolved === object)
        }
    }

    @Suite("Remove")
    struct RemoveTests {

        private var container: NerdzInject { .shared }

        @Test func testWhenRemoveExistingIdentifierShouldReturnTrueAndClearRegistration() {
            // Arrange
            let identifier = "remove.existing.identifier"
            let object = TestData.makeInstance()
            container.registerObject(object, for: identifier)

            // Act
            let didRemove = container.remove(by: identifier)
            let resolved: Instance? = container.resolve(by: identifier)

            // Assert
            #expect(didRemove == true)
            #expect(resolved == nil)
        }

        @Test func testWhenRemoveMissingIdentifierShouldReturnFalse() {
            // Arrange
            let identifier = "remove.missing.identifier"

            // Act
            let didRemove = container.remove(by: identifier)

            // Assert
            #expect(didRemove == false)
        }

        @Test func testWhenRemoveByTypeShouldReturnTrueAndClearRegistration() {
            // Arrange
            let object = RemoveByType()
            container.registerObject(object)

            // Act
            let didRemove = container.remove(by: RemoveByType.self)
            let resolved: RemoveByType? = container.resolve()

            // Assert
            #expect(didRemove == true)
            #expect(resolved == nil)
        }
    }

    @Suite("Singleton Caching")
    struct SingletonCachingTests {

        private var container: NerdzInject { .shared }

        @Test func testWhenSingletonTrueForTypeShouldReturnSameInstanceOnRepeatedResolve() {
            // Arrange
            defer { container.remove(by: SingletonTypeBased.self) }
            container.register(singleton: true, for: SingletonTypeBased.self) { SingletonTypeBased() }

            // Act
            let first: SingletonTypeBased? = container.resolve(by: SingletonTypeBased.self)
            let second: SingletonTypeBased? = container.resolve(by: SingletonTypeBased.self)

            // Assert
            #expect(first === second)
        }

        @Test func testWhenSingletonTrueForClosureShouldReturnSameInstanceOnRepeatedResolve() {
            // Arrange
            defer { container.remove(by: SingletonClosureBased.self) }
            container.register(singleton: true) { SingletonClosureBased() }

            // Act
            let first: SingletonClosureBased? = container.resolve()
            let second: SingletonClosureBased? = container.resolve()

            // Assert
            #expect(first === second)
        }

        @Test func testWhenSingletonFalseShouldReturnFreshInstancesOnRepeatedResolve() {
            // Arrange
            defer { container.remove(by: NonSingletonType.self) }
            container.register(singleton: false) { NonSingletonType() }

            // Act
            let first: NonSingletonType? = container.resolve()
            let second: NonSingletonType? = container.resolve()

            // Assert
            #expect(first !== second)
        }
    }

    @Suite("Concurrency")
    struct ConcurrencyTests {

        private var container: NerdzInject { .shared }

        @Test func testWhenConcurrentRegisterAndResolveShouldRemainConsistent() {
            // Arrange
            let iterations = 1_000
            let identifierPrefix = "concurrency.smoke"
            let mismatchLock = NSLock()
            var mismatchCount = 0

            // Act
            DispatchQueue.concurrentPerform(iterations: iterations) { index in
                let identifier = "\(identifierPrefix).\(index)"
                let expected = index

                container.registerObject(expected, for: identifier)
                let resolved: Int? = container.resolve(by: identifier)
                container.remove(by: identifier)

                if resolved != expected {
                    mismatchLock.lock()
                    mismatchCount += 1
                    mismatchLock.unlock()
                }
            }

            // Assert
            #expect(mismatchCount == 0)
        }
    }
}
