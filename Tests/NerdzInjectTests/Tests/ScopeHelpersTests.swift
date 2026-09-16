import Testing
import NerdzInject

@Suite("Scope Helpers")
struct ScopeHelpersTests {

    private final class Service {
        let tag: String
        init(tag: String) { self.tag = tag }
    }

    private final class Holder {
        @ForceInject var service: Service
    }

    @Test func testWhenWithDependenciesSyncShouldResolveConfiguredInstance() {
        let expectedTag = "sync"

        let tag = withDependencies {
            $0.registerObject(Service(tag: expectedTag))
        } operation: {
            Holder().service.tag
        }
        #expect(tag == expectedTag)
    }

    @Test func testWhenWithDependenciesAsyncShouldResolveConfiguredInstance() async {
        let expectedTag = "async"

        let tag = await withDependencies {
            $0.registerObject(Service(tag: expectedTag))
        } operation: { () async -> String in
            Holder().service.tag
        }
        #expect(tag == expectedTag)
    }

    @Test func testWhenSutBuiltInScopeShouldRetainOverrideAfterScope() {
        let expectedTag = "sticky"

        let holder = withDependencies {
            $0.registerObject(Service(tag: expectedTag))
        } operation: {
            Holder()
        }
        #expect(holder.service.tag == expectedTag)
    }

    @Test func testWhenWithDependenciesUsedShouldNotLeakToShared() {
        let expectedTag = "isolated"
        withDependencies {
            $0.registerObject(Service(tag: expectedTag))
        } operation: {
            _ = Holder().service
        }
        let leaked: Service? = NerdzInject.shared.resolve()
        #expect(leaked == nil)
    }
}
