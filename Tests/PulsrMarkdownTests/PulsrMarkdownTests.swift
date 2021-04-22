    import XCTest
    @testable import PulsrMarkdown

    final class PulsrMarkdownTests: XCTestCase {
        func testStrings() {
            let g = MarkdownGenerator.default
            XCTAssertEqual(g.generate(string: "This is **bold**, *italic* and *crossed **like this* Hehe**").string, "This is bold, italic and crossed like this Hehe")
            XCTAssertEqual(g.generate(string: "This is \\*escaped\\*").string, "This is *escaped*")
            XCTAssertEqual(g.generate(string: "This is `raw\\`").string, "This is raw\\")
            XCTAssertEqual(g.generate(string: "This is `invalid").string, "This is `invalid")
            XCTAssertEqual(g.generate(string: "Hello this <<does nothing>> ok?").string, "Hello this <<does nothing>> ok?")
            XCTAssertEqual(g.generate(string: "> This is a quote\nThis isn't").string, "This is a quote\nThis isn't")
            XCTAssertEqual(g.generate(string: "`This will not\nbe parsed`").string, "`This will not\nbe parsed`")
            XCTAssertEqual(g.generate(string: "This will not``\n``be parsed").string, "This will not``\n``be parsed")
            XCTAssertEqual(g.generate(string: "```This will \nbe parsed```").string, "This will \nbe parsed")
        }
    }
