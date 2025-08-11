import SwiftUI

struct NewTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var taskStore: TaskStore

    @State private var draft = TaskItem.newDraft()

    var body: some View {
        NavigationStack {
            Form {
                Section("Basics") {
                    TextField("Title", text: $draft.title)
                    TextField("Description", text: Binding(get: { draft.description ?? "" }, set: { draft.description = $0 }))
                }
                Section("Meta") {
                    Picker("Assignee", selection: $draft.assignee) {
                        ForEach(TaskItem.Assignee.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) }
                    }
                    Picker("Status", selection: $draft.status) {
                        ForEach(TaskItem.Status.allCases, id: \.self) { Text($0.rawValue.replacingOccurrences(of: "_", with: " ").capitalized).tag($0) }
                    }
                    TextField("Category", text: Binding(get: { draft.category ?? "" }, set: { draft.category = $0 }))
                    DatePicker("Due Date", selection: Binding(get: { draft.dueDate ?? Date() }, set: { draft.dueDate = $0 }), displayedComponents: .date)
                }
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) { Button("Add") { Task { await taskStore.add(draft); dismiss() } } }
            }
        }
    }
}