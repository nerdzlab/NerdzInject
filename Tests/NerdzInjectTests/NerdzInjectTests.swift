import XCTest
@testable import NerdzInject

final class NerdzInjectTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(NerdzInject().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
