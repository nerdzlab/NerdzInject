import Testing
import NerdzInject

@Suite("Dependency Resolver")
struct DependencyResolverTests {

    private final class Service {
        let tag: String
        init(tag: String) { self.tag = tag }
    }

    private final class Consumer {
        let service: Service
        init(resolver: DependencyResolver) { self.service = resolver.forceResolve() }
    }

    @Test func testWhenConstructorInjectedResolverShouldResolveFromThatContainer() {
        let expectedTag = "injected"
        let container = NerdzInject()
        container.registerObject(Service(tag: expectedTag))

        let consumer = Consumer(resolver: container)
        #expect(consumer.service.tag == expectedTag)
    }
}
