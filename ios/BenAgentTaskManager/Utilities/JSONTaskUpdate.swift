import Foundation

struct AITaskOperation: Codable, Equatable {
    enum OperationType: String, Codable { case create, update, complete, delete }
    var type: OperationType
    var id: UUID?
    var title: String?
    var description: String?
    var assignee: TaskItem.Assignee?
    var status: TaskItem.Status?
    var category: String?
    var dueDate: Date?
}

struct AITaskUpdatePayload: Codable, Equatable {
    var operations: [AITaskOperation]
    var message: String?
}

enum AIPayloadParser {
    static func extractPayload(from text: String) -> AITaskUpdatePayload? {
        // Look for a JSON object in the message, e.g., fenced or inline
        let patterns = [
            #"```json\s*([\s\S]*?)```"#,
            #"###TASK_UPDATE###\s*(\{[\s\S]*\})"#,
            #"(\{\s*\"operations\"[\s\S]*\})"#
        ]
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let ns = text as NSString
                let range = NSRange(location: 0, length: ns.length)
                if let match = regex.firstMatch(in: text, options: [], range: range), match.numberOfRanges > 1 {
                    let jsonString = ns.substring(with: match.range(at: 1))
                    if let data = jsonString.data(using: .utf8) {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        if let payload = try? decoder.decode(AITaskUpdatePayload.self, from: data) {
                            return payload
                        }
                    }
                }
            }
        }
        return nil
    }
}