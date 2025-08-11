import Foundation
import Combine

final class TaskStore: ObservableObject {
    enum Filter: String, CaseIterable { case all, ben, agent, completed }

    @Published private(set) var tasks: [TaskItem] = []
    @Published var filter: Filter = .all

    private let supabase = SupabaseService()
    private var subscriptions = Set<AnyCancellable>()

    func configure(with config: AppConfig) {
        if let url = config.supabaseURL { supabase.configure(url: url, anonKey: config.supabaseAnonKey) }
        Task { await refresh() }
        supabase.subscribe { [weak self] in
            Task { await self?.refresh() }
        }
    }

    @MainActor
    func refresh() async {
        do {
            let fetched = try await supabase.fetchTasks()
            self.tasks = fetched
        } catch {
            print("Fetch tasks error: \(error)")
        }
    }

    func filteredTasks() -> [TaskItem] {
        switch filter {
        case .all: return tasks
        case .ben: return tasks.filter { $0.assignee == .ben && $0.status != .done }
        case .agent: return tasks.filter { $0.assignee == .agent && $0.status != .done }
        case .completed: return tasks.filter { $0.status == .done }
        }
    }

    func add(_ draft: TaskItem) async {
        do {
            let created = try await supabase.createTask(draft)
            await refresh()
            print("Created: \(created.id)")
        } catch { print(error) }
    }

    func update(_ item: TaskItem) async {
        do { _ = try await supabase.updateTask(item); await refresh() } catch { print(error) }
    }

    func complete(_ id: UUID) async {
        guard var item = tasks.first(where: { $0.id == id }) else { return }
        item.status = .done
        await update(item)
    }

    func delete(_ id: UUID) async {
        do { try await supabase.deleteTask(id: id); await refresh() } catch { print(error) }
    }

    func apply(aiPayload: AITaskUpdatePayload) async {
        for op in aiPayload.operations {
            switch op.type {
            case .create:
                var draft = TaskItem.newDraft()
                draft.title = op.title ?? draft.title
                draft.description = op.description
                draft.assignee = op.assignee ?? .ben
                draft.status = op.status ?? .pending
                draft.category = op.category
                draft.dueDate = op.dueDate
                await add(draft)
            case .update:
                guard let id = op.id, var item = tasks.first(where: { $0.id == id }) else { continue }
                if let v = op.title { item.title = v }
                if let v = op.description { item.description = v }
                if let v = op.assignee { item.assignee = v }
                if let v = op.status { item.status = v }
                if let v = op.category { item.category = v }
                if let v = op.dueDate { item.dueDate = v }
                await update(item)
            case .complete:
                if let id = op.id { await complete(id) }
            case .delete:
                if let id = op.id { await delete(id) }
            }
        }
    }

    func dailySummaryText() -> String {
        let open = tasks.filter { $0.status != .done }
        let dueToday = open.filter { Calendar.current.isDateInToday($0.dueDate ?? Date.distantPast) }
        return "Open: \(open.count), Due Today: \(dueToday.count)"
    }
}