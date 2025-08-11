import Foundation

final class ChatViewModel: ObservableObject {
    @Published private(set) var messages: [AIMessage] = []

    private let ai = AIService()
    private weak var taskStore: TaskStore?

    func configure(with config: AppConfig, taskStore: TaskStore) {
        ai.configure(openAIKey: config.openAIKey)
        self.taskStore = taskStore
    }

    @MainActor
    func send(_ text: String) async {
        messages.append(AIMessage(role: .user, text: text))
        guard let taskStore else { return }
        do {
            let (reply, payload) = try await ai.send(userMessage: text, tasksContext: taskStore.filteredTasks(), history: messages)
            if let payload {
                await taskStore.apply(aiPayload: payload)
            }
            messages.append(AIMessage(role: .assistant, text: reply))
        } catch {
            messages.append(AIMessage(role: .assistant, text: "Sorry, there was an error."))
        }
    }
}