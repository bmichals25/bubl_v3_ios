import SwiftUI

@main
struct BenAgentTaskManagerApp: App {
    @StateObject private var appConfig = AppConfig()
    @StateObject private var taskStore = TaskStore()
    @StateObject private var chatViewModel = ChatViewModel()
    @StateObject private var notificationScheduler = NotificationScheduler()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appConfig)
                .environmentObject(taskStore)
                .environmentObject(chatViewModel)
                .environmentObject(notificationScheduler)
                .onAppear {
                    appConfig.bootstrapIfPossible()
                    if appConfig.isConfigured {
                        taskStore.configure(with: appConfig)
                        chatViewModel.configure(with: appConfig, taskStore: taskStore)
                        notificationScheduler.configure(taskStore: taskStore)
                        notificationScheduler.requestAuthorizationAndSchedule()
                    }
                }
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var appConfig: AppConfig
    @EnvironmentObject private var taskStore: TaskStore
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @EnvironmentObject private var notificationScheduler: NotificationScheduler

    var body: some View {
        TabView {
            TaskListView()
                .tabItem { Label("Tasks", systemImage: "checklist") }
            ChatView()
                .tabItem { Label("Chat", systemImage: "bubble.left.and.text.bubble.right") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(.blue)
        .onChange(of: appConfig.isConfigured) { _, isOn in
            guard isOn else { return }
            if let url = appConfig.supabaseURL {
                taskStore.configure(with: appConfig)
                chatViewModel.configure(with: appConfig, taskStore: taskStore)
                notificationScheduler.configure(taskStore: taskStore)
                notificationScheduler.requestAuthorizationAndSchedule()
            }
        }
    }
}