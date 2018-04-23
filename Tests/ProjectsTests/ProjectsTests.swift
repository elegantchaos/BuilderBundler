import XCTest
@testable import Projects

final class ProjectsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Projects().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
