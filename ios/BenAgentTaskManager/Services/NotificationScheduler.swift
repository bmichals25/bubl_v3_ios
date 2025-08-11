import Foundation
import UserNotifications

final class NotificationScheduler: ObservableObject {
    private weak var taskStore: TaskStore?

    func configure(taskStore: TaskStore) {
        self.taskStore = taskStore
    }

    func requestAuthorizationAndSchedule() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            self.scheduleDailySummaries()
        }
    }

    func scheduleDailySummaries() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        schedule(atHour: 8)
        schedule(atHour: 17)
    }

    private func schedule(atHour hour: Int) {
        let tz = TimeZone(identifier: "America/New_York") ?? .current
        var date = Date()
        var calendar = Calendar.current
        calendar.timeZone = tz

        var comps = calendar.dateComponents([.year, .month, .day], from: date)
        comps.hour = hour
        comps.minute = 0
        comps.second = 0
        let target = calendar.date(from: comps) ?? date
        let fireDate = target > date ? target : calendar.date(byAdding: .day, value: 1, to: target) ?? target
        let triggerDate = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .timeZone], from: fireDate)

        let content = UNMutableNotificationContent()
        content.title = "Task Summary"
        content.body = self.taskStore?.dailySummaryText() ?? "Check your tasks for today."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        let id = "daily-summary-\(hour)"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}