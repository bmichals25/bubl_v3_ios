import SwiftUI

struct TaskListView: View {
    @EnvironmentObject private var taskStore: TaskStore
    @State private var showNew = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar
                List {
                    ForEach(taskStore.filteredTasks()) { task in
                        NavigationLink(value: task) {
                            TaskRow(task: task)
                        }
                        .swipeActions {
                            Button(role: .destructive) { Task { await taskStore.delete(task.id) } } label: { Label("Delete", systemImage: "trash") }
                            if task.status != .done {
                                Button { Task { await taskStore.complete(task.id) } } label: { Label("Done", systemImage: "checkmark.circle") }
                                    .tint(.green)
                            }
                        }
                    }
                }
                .navigationDestination(for: TaskItem.self) { task in
                    TaskDetailView(task: task)
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showNew = true } label: { Image(systemName: "plus") }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { Task { await taskStore.refresh() } } label: { Image(systemName: "arrow.clockwise") }
                }
            }
            .sheet(isPresented: $showNew) {
                NewTaskView()
            }
        }
    }

    private var filterBar: some View {
        Picker("Filter", selection: $taskStore.filter) {
            Text("All").tag(TaskStore.Filter.all)
            Text("Ben").tag(TaskStore.Filter.ben)
            Text("Agent").tag(TaskStore.Filter.agent)
            Text("Completed").tag(TaskStore.Filter.completed)
        }
        .pickerStyle(.segmented)
        .padding([.horizontal, .top])
    }
}

private struct TaskRow: View {
    let task: TaskItem
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title).font(.headline)
                if let desc = task.description, !desc.isEmpty {
                    Text(desc).font(.subheadline).foregroundColor(.secondary).lineLimit(1)
                }
                HStack(spacing: 8) {
                    Label(task.assignee.rawValue.capitalized, systemImage: task.assignee == .ben ? "person" : "cpu")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Label(task.status.rawValue.replacingOccurrences(of: "_", with: " "), systemImage: "flag")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if let due = task.dueDate {
                        Label(due, style: .date).font(.caption).foregroundColor(.secondary)
                    }
                }
            }
            Spacer()
            if task.status == .done { Image(systemName: "checkmark.circle.fill").foregroundColor(.green) }
        }
        .padding(.vertical, 4)
    }
}