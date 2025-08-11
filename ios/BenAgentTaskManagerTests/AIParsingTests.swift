import XCTest
@testable import BenAgentTaskManager

final class AIParsingTests: XCTestCase {
    func testExtractsJSONInFence() throws {
        let text = """
        Here's what I'll do.
        ```json
        {"operations":[{"type":"create","title":"Test","assignee":"ben","status":"pending"}],"message":"ok"}
        ```
        """
        let payload = AIPayloadParser.extractPayload(from: text)
        XCTAssertNotNil(payload)
        XCTAssertEqual(payload?.operations.first?.type, .create)
    }

    func testExtractsInline() throws {
        let text = "{\"operations\":[{\"type\":\"complete\",\"id\":\"00000000-0000-0000-0000-000000000000\"}]}"
        let payload = AIPayloadParser.extractPayload(from: text)
        XCTAssertNotNil(payload)
        XCTAssertEqual(payload?.operations.first?.type, .complete)
    }
}