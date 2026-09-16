import Testing
import NerdzInject

@Suite("Ambient Container")
struct AmbientContainerTests {

    private final class Service {
        let tag: String
        init(tag: String) { self.tag = tag }
    }

    private final class Holder {
        @ForceInject var service: Service
    }

    @Test func testWhenNoOverrideShouldDefaultCurrentToShared() {
        #expect(NerdzInject.current === NerdzInject.shared)
    }

    @Test func testWhenNewContainerCreatedShouldBeIndependentInstance() {
        let container = NerdzInject()
        #expect(container !== NerdzInject.shared)
    }

    @Test func testWhenConstructedInScopeShouldRetainContainerAfterScopeExits() {
        let expectedTag = "captured"
        let container = NerdzInject()
        container.registerObject(Service(tag: expectedTag))

        // Constructed INSIDE the scope, so the wrapper captures `container`.
        let holder = NerdzInject.$current.withValue(container) { Holder() }

        // Accessed AFTER the scope has exited: still resolves the override.
        #expect(holder.service.tag == expectedTag)
    }

    @Test func testWhenConstructedOutsideScopeShouldResolveFromShared() {
        let expectedTag = "shared"
        NerdzInject.shared.registerObject(Service(tag: expectedTag))
        defer { NerdzInject.shared.remove(by: Service.self) }

        let holder = Holder()   // constructed outside any scope, captures .shared
        #expect(holder.service.tag == expectedTag)
    }
}
