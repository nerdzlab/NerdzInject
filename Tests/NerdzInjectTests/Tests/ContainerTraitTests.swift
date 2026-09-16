import Testing
import NerdzInject
import NerdzInjectTesting

@Suite("Container Trait")
struct ContainerTraitTests {

    private final class Service {
        let tag: String
        init(tag: String) { self.tag = tag }
    }

    @Test(.nerdzContainer) func testWhenTraitAppliedShouldUseFreshContainer() {
        let expectedTag = "trait"
        NerdzInject.current.registerObject(Service(tag: expectedTag))
        let service: Service = NerdzInject.current.forceResolve()
        #expect(service.tag == expectedTag)
    }

    @Test(.nerdzContainer) func testWhenTraitAppliedShouldNotLeakFromOtherTests() {
        // A fresh container means nothing registered by other tests is visible.
        let service: Service? = NerdzInject.current.resolve()
        #expect(service == nil)
    }
}
