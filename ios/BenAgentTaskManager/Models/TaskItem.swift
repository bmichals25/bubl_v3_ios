import Foundation

struct TaskItem: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var description: String?
    var assignee: Assignee
    var status: Status
    var category: String?
    var dueDate: Date?
    var createdAt: Date
    var updatedAt: Date

    enum Assignee: String, Codable, CaseIterable { case ben, agent }
    enum Status: String, Codable, CaseIterable { case pending, in_progress, done }

    enum CodingKeys: String, CodingKey {
        case id, title, description, assignee, status, category
        case dueDate = "due_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

extension TaskItem {
    static func newDraft() -> TaskItem {
        TaskItem(
            id: UUID(),
            title: "",
            description: nil,
            assignee: .ben,
            status: .pending,
            category: nil,
            dueDate: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}