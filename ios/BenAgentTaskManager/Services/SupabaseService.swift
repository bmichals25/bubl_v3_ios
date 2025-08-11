import Foundation
import Combine
import Supabase

final class SupabaseService {
    private var client: SupabaseClient?
    private var realtimeSubscription: RealtimeChannel?

    func configure(url: URL, anonKey: String) {
        client = SupabaseClient(supabaseURL: url, supabaseKey: anonKey)
    }

    func fetchTasks() async throws -> [TaskItem] {
        guard let client else { return [] }
        let response: [TaskItemDTO] = try await client.database
            .from("tasks")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
        return response.map { $0.toModel() }
    }

    func createTask(_ task: TaskItem) async throws -> TaskItem {
        guard let client else { return task }
        var dto = TaskItemDTO.fromModel(task)
        dto.id = nil // Let DB generate
        let inserted: [TaskItemDTO] = try await client.database
            .from("tasks")
            .insert(dto)
            .select()
            .execute()
            .value
        return inserted.first?.toModel() ?? task
    }

    func updateTask(_ task: TaskItem) async throws -> TaskItem {
        guard let client else { return task }
        let dto = TaskItemDTO.fromModel(task)
        let updated: [TaskItemDTO] = try await client.database
            .from("tasks")
            .update(dto)
            .eq("id", value: task.id.uuidString)
            .select()
            .execute()
            .value
        return updated.first?.toModel() ?? task
    }

    func deleteTask(id: UUID) async throws {
        guard let client else { return }
        _ = try await client.database
            .from("tasks")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }

    func subscribe(onChange: @escaping () -> Void) {
        guard let client else { return }
        realtimeSubscription?.unsubscribe()
        let channel = client.realtime.channel("public:tasks")
        channel.on(RealtimeChannelEvent.insert) { _ in onChange() }
        channel.on(RealtimeChannelEvent.update) { _ in onChange() }
        channel.on(RealtimeChannelEvent.delete) { _ in onChange() }
        channel.subscribe()
        realtimeSubscription = channel
    }
}

// MARK: - DTOs for DB mapping

struct TaskItemDTO: Codable {
    var id: String?
    var title: String
    var description: String?
    var assignee: String
    var status: String
    var category: String?
    var due_date: String?
    var created_at: String?
    var updated_at: String?

    func toModel() -> TaskItem {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let dateOnly = DateFormatter()
        dateOnly.calendar = Calendar(identifier: .iso8601)
        dateOnly.dateFormat = "yyyy-MM-dd"
        return TaskItem(
            id: UUID(uuidString: id ?? UUID().uuidString) ?? UUID(),
            title: title,
            description: description,
            assignee: TaskItem.Assignee(rawValue: assignee) ?? .ben,
            status: TaskItem.Status(rawValue: status) ?? .pending,
            category: category,
            dueDate: due_date.flatMap { dateOnly.date(from: $0) ?? iso.date(from: $0) },
            createdAt: created_at.flatMap { iso.date(from: $0) } ?? Date(),
            updatedAt: updated_at.flatMap { iso.date(from: $0) } ?? Date()
        )
    }

    static func fromModel(_ model: TaskItem) -> TaskItemDTO {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let dateOnly = DateFormatter()
        dateOnly.calendar = Calendar(identifier: .iso8601)
        dateOnly.dateFormat = "yyyy-MM-dd"
        return TaskItemDTO(
            id: model.id.uuidString,
            title: model.title,
            description: model.description,
            assignee: model.assignee.rawValue,
            status: model.status.rawValue,
            category: model.category,
            due_date: model.dueDate.map { dateOnly.string(from: $0) },
            created_at: iso.string(from: model.createdAt),
            updated_at: iso.string(from: model.updatedAt)
        )
    }
}