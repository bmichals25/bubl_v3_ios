import Foundation

struct AIMessage: Identifiable, Equatable {
    enum Role { case user, assistant }
    var id = UUID()
    var role: Role
    var text: String
}

final class AIService {
    private var openAIKey: String = ""

    func configure(openAIKey: String) {
        self.openAIKey = openAIKey
    }

    func send(userMessage: String, tasksContext: [TaskItem], history: [AIMessage]) async throws -> (reply: String, payload: AITaskUpdatePayload?) {
        let systemPrompt = """
        You are Ben–Agent, a helpful task manager assistant. You can propose task changes as JSON.
        When you intend to change tasks, include a single JSON object with key "operations" representing an array of operations.
        Prefer this fenced form:
        ```json
        {"operations":[{"type":"create","title":"...","assignee":"ben","status":"pending","dueDate":"2025-01-31T00:00:00Z"}],"message":"Short note to user"}
        ```
        Allowed operation.type values: create, update, complete, delete
        Use ISO8601 for dates.
        """
        let tasksSummary = tasksContext.filter { $0.status != .done }.map { t in
            "- [\(t.status.rawValue)] (\(t.assignee.rawValue)) \(t.title) due: \(t.dueDate?.iso8601String() ?? "-") id: \(t.id.uuidString)"
        }.joined(separator: "\n")

        var messages: [[String: String]] = []
        messages.append(["role": "system", "content": systemPrompt])
        if !tasksSummary.isEmpty {
            messages.append(["role": "system", "content": "Open tasks:\n\(tasksSummary)"])
        }
        for m in history.suffix(6) { // keep last few for brevity
            messages.append(["role": m.role == .user ? "user" : "assistant", "content": m.text])
        }
        messages.append(["role": "user", "content": userMessage])

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "temperature": 0.2,
            "messages": messages
        ]
        let data = try JSONSerialization.data(withJSONObject: body)
        var req = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        req.httpMethod = "POST"
        req.httpBody = data
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")

        let (respData, _) = try await URLSession.shared.data(for: req)
        let replyText = try Self.extractContent(from: respData)
        let payload = AIPayloadParser.extractPayload(from: replyText)
        return (replyText, payload)
    }

    private static func extractContent(from data: Data) throws -> String {
        struct Choice: Decodable { let message: Msg }
        struct Msg: Decodable { let content: String }
        struct Resp: Decodable { let choices: [Choice] }
        let r = try JSONDecoder().decode(Resp.self, from: data)
        return r.choices.first?.message.content ?? ""
    }
}

private extension Date {
    func iso8601String() -> String { ISO8601DateFormatter().string(from: self) }
}