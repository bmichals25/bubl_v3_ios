import SwiftUI

struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var taskStore: TaskStore

    @State var task: TaskItem

    var body: some View {
        Form {
            Section("Basics") {
                TextField("Title", text: $task.title)
                TextField("Description", text: Binding(get: { task.description ?? "" }, set: { task.description = $0 }))
            }
            Section("Meta") {
                Picker("Assignee", selection: $task.assignee) {
                    ForEach(TaskItem.Assignee.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) }
                }
                Picker("Status", selection: $task.status) {
                    ForEach(TaskItem.Status.allCases, id: \.self) { Text($0.rawValue.replacingOccurrences(of: "_", with: " ").capitalized).tag($0) }
                }
                TextField("Category", text: Binding(get: { task.category ?? "" }, set: { task.category = $0 }))
                DatePicker("Due Date", selection: Binding(get: { task.dueDate ?? Date() }, set: { task.dueDate = $0 }), displayedComponents: .date)
            }
        }
        .navigationTitle("Edit Task")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") { Task { await taskStore.update(task); dismiss() } }
            }
        }
    }
}