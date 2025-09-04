import Foundation
import UserNotifications
import SwiftUI

    @MainActor
    class SleepViewModel: ObservableObject {
            @Published var sleepRecords: [SleepRecord] = []
    @Published var currentBedtime: Date?
    @Published var isSleeping = false
    @Published var currentFatigueLevel: Int = 3
    @Published var currentBedtimeMessage: String = ""
        
        // 앱이 포그라운드로 올 때 자동 기상 체크
        private var appDidBecomeActiveObserver: NSObjectProtocol?
    
    @AppStorage("sleepGoal") private var sleepGoal: Double = 8.0
    @AppStorage("sleepRecordsData") private var sleepRecordsData: Data = Data()
    
    private let userDefaults = UserDefaults.standard
    private let sleepRecordsKey = "sleepRecords"
    
    init() {
        loadSleepRecords()
        requestNotificationPermission()
        setupAppLifecycleObserver()
    }
    
    // MARK: - Data Management
    
    private func loadSleepRecords() {
        guard let data = userDefaults.data(forKey: sleepRecordsKey),
              let records = try? JSONDecoder().decode([SleepRecord].self, from: data) else {
            return
        }
        sleepRecords = records.sorted { $0.date > $1.date }
    }
    
    private func saveSleepRecords() {
        guard let data = try? JSONEncoder().encode(sleepRecords) else { return }
        userDefaults.set(data, forKey: sleepRecordsKey)
    }
    
    // MARK: - Sleep Tracking
    
    func startSleep() {
        currentBedtime = Date()
        isSleeping = true
        scheduleWakeUpNotification()
        print("🌙 취침 기록 완료: \(currentBedtime?.formatted(date: .omitted, time: .shortened) ?? "")")
    }
    
    func wakeUp() {
        guard let bedtime = currentBedtime else { return }
        
        let wakeTime = Date()
        let record = SleepRecord(
            bedtime: bedtime, 
            wakeTime: wakeTime, 
            fatigueLevel: currentFatigueLevel, 
            bedtimeMessage: currentBedtimeMessage
        )
        
        sleepRecords.append(record)
        saveSleepRecords()
        
        currentBedtime = nil
        isSleeping = false
        currentFatigueLevel = 3
        currentBedtimeMessage = ""
        
        print("🌅 기상 기록 완료: \(record.formattedDuration)")
    }
    
    func cancelSleep() {
        currentBedtime = nil
        isSleeping = false
        print("❌ 수면 취소됨")
    }
    
    // MARK: - Notifications
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    private func scheduleWakeUpNotification() {
        guard let bedtime = currentBedtime else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "좋은 아침이에요! 🌅"
        content.body = "자라가 당신의 기상 시간을 기록할 준비가 되었어요!"
        content.sound = .default
        
        let wakeUpTime = bedtime.addingTimeInterval(sleepGoal * 3600)
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: wakeUpTime),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "wakeUpNotification",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification scheduling error: \(error)")
            }
        }
    }
    
    // MARK: - Data Queries
    
    var recentRecords: [SleepRecord] {
        return Array(sleepRecords.prefix(7))
    }
    
    var averageSleepDuration: Double {
        guard !sleepRecords.isEmpty else { return 0 }
        let totalHours = sleepRecords.reduce(0) { $0 + $1.durationHours }
        return totalHours / Double(sleepRecords.count)
    }
    
    func recordsForLastDays(_ days: Int) -> [SleepRecord] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -days, to: endDate) ?? endDate
        
        return sleepRecords.filter { record in
            record.date >= startDate && record.date <= endDate
        }
    }
    
    // MARK: - Settings
    
    func updateSleepGoal(_ newGoal: Double) {
        sleepGoal = newGoal
    }
    
    var currentSleepGoal: Double {
        return sleepGoal
    }
    
    // MARK: - App Lifecycle
    
    private func setupAppLifecycleObserver() {
        appDidBecomeActiveObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.checkForWakeUp()
        }
    }
    
    private func checkForWakeUp() {
        // 수면 중이고 취침 시간이 설정되어 있으면 자동으로 기상 기록
        if isSleeping, let bedtime = currentBedtime {
            // 취침 후 최소 1시간이 지났는지 확인 (실수로 바로 기상되는 것 방지)
            let minimumSleepTime: TimeInterval = 3600 // 1시간
            let timeSinceBedtime = Date().timeIntervalSince(bedtime)
            
            if timeSinceBedtime >= minimumSleepTime {
                print("🌅 앱 활성화로 자동 기상 체크")
                wakeUp()
            }
        }
    }
    
    deinit {
        if let observer = appDidBecomeActiveObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
} 