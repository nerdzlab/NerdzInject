import Testing
import NerdzInject

/// A Swift Testing trait that runs each test with a fresh, isolated
/// ``NerdzInject`` container bound to `NerdzInject.current`.
///
/// Apply it as `@Test(.nerdzContainer)` or `@Suite(.nerdzContainer)`. Any type
/// constructed in the test body captures the fresh container, and nothing
/// registered by other tests is visible, so parallel tests stay isolated
/// without manual cleanup.
public struct NerdzContainerTrait: TestTrait, SuiteTrait, TestScoping {

    public func provideScope(
        for test: Test,
        testCase: Test.Case?,
        performing function: @Sendable () async throws -> Void
    ) async throws {
        try await NerdzInject.$current.withValue(NerdzInject()) {
            try await function()
        }
    }

    public func scopeProvider(for test: Test, testCase: Test.Case?) -> Self? {
        self
    }
}

public extension Trait where Self == NerdzContainerTrait {
    /// Runs each test with a fresh, isolated ``NerdzInject`` container.
    static var nerdzContainer: Self { NerdzContainerTrait() }
}
