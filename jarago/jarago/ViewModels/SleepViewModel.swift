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
    @Published var currentInsomniaMessages: [InsomniaMessage] = []
        
        // 앱이 포그라운드로 올 때 자동 기상 체크
        private var appDidBecomeActiveObserver: NSObjectProtocol?
    
    @AppStorage("sleepGoal") private var sleepGoal: Double = 8.0
    @AppStorage("sleepRecordsData") private var sleepRecordsData: Data = Data()
    @AppStorage("currentBedtimeData") private var currentBedtimeData: Data = Data()
    @AppStorage("isSleepingData") private var isSleepingData: Bool = false
    @AppStorage("currentFatigueLevelData") private var currentFatigueLevelData: Int = 3
    @AppStorage("currentBedtimeMessageData") private var currentBedtimeMessageData: String = ""
    @AppStorage("currentInsomniaMessagesData") private var currentInsomniaMessagesData: Data = Data()
    
    private let userDefaults = UserDefaults.standard
    private let sleepRecordsKey = "sleepRecords"
    
    init() {
        loadSleepRecords()
        loadCurrentState()
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
    
    func saveCurrentState() {
        // 현재 취침 시간 저장
        if let bedtime = currentBedtime,
           let data = try? JSONEncoder().encode(bedtime) {
            currentBedtimeData = data
        }
        
        // 수면 중 상태 저장
        isSleepingData = isSleeping
        
        // 피곤함 정도 저장
        currentFatigueLevelData = currentFatigueLevel
        
        // 자기 전 한마디 저장
        currentBedtimeMessageData = currentBedtimeMessage
        
        // 불면 메시지들 저장
        if let data = try? JSONEncoder().encode(currentInsomniaMessages) {
            currentInsomniaMessagesData = data
        }
    }
    
    private func loadCurrentState() {
        // 현재 취침 시간 복원
        if let data = try? JSONDecoder().decode(Date.self, from: currentBedtimeData) {
            currentBedtime = data
        }
        
        // 수면 중 상태 복원
        isSleeping = isSleepingData
        
        // 피곤함 정도 복원
        currentFatigueLevel = currentFatigueLevelData
        
        // 자기 전 한마디 복원
        currentBedtimeMessage = currentBedtimeMessageData
        
        // 불면 메시지들 복원
        if let data = try? JSONDecoder().decode([InsomniaMessage].self, from: currentInsomniaMessagesData) {
            currentInsomniaMessages = data
        }
    }
    
    // MARK: - Sleep Tracking
    
    func startSleep() {
        currentBedtime = Date()
        isSleeping = true
        saveCurrentState()
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
            bedtimeMessage: currentBedtimeMessage,
            insomniaMessages: currentInsomniaMessages
        )
        
        sleepRecords.append(record)
        saveSleepRecords()
        
        currentBedtime = nil
        isSleeping = false
        currentFatigueLevel = 3
        currentBedtimeMessage = ""
        currentInsomniaMessages = []
        saveCurrentState()
        
        print("🌅 기상 기록 완료: \(record.formattedDuration)")
        
        // 오늘의 수면 요약 표시
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NotificationCenter.default.post(name: NSNotification.Name("ShowTodaySummary"), object: nil)
        }
    }
    
    func addInsomniaMessage(_ message: String) {
        let newMessage = InsomniaMessage(message: message)
        currentInsomniaMessages.append(newMessage)
        saveCurrentState()
        print("💬 불면 메시지 추가: \(message)")
    }
    
    func cancelSleep() {
        guard let bedtime = currentBedtime else { return }
        
        let wakeTime = Date()
        let record = SleepRecord(
            bedtime: bedtime, 
            wakeTime: wakeTime, 
            fatigueLevel: currentFatigueLevel, 
            bedtimeMessage: currentBedtimeMessage,
            insomniaMessages: currentInsomniaMessages
        )
        
        sleepRecords.append(record)
        saveSleepRecords()
        
        currentBedtime = nil
        isSleeping = false
        currentFatigueLevel = 3
        currentBedtimeMessage = ""
        currentInsomniaMessages = []
        saveCurrentState()
        
        print("❌ 수면 취소됨 - 기록 저장됨: \(record.formattedDuration)")
        
        // 오늘의 수면 요약 표시
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NotificationCenter.default.post(name: NSNotification.Name("ShowTodaySummary"), object: nil)
        }
    }
    
    func resetToInitialState() {
        print("🔄 초기 상태로 리셋 시작")
        cancelSleep()
        // 첫 번째 탭(취침)으로 이동하도록 알림
        NotificationCenter.default.post(name: NSNotification.Name("ResetToSleepTab"), object: nil)
        // ActiveSleepView 닫기 알림
        NotificationCenter.default.post(name: NSNotification.Name("DismissActiveSleepView"), object: nil)
        print("🔄 초기 상태로 리셋 완료")
    }
    
    func deleteAllRecords() {
        print("🗑️ 모든 수면 기록 삭제 시작")
        
        // 수면 기록 삭제
        sleepRecords.removeAll()
        saveSleepRecords()
        
        // 현재 상태 초기화
        currentBedtime = nil
        isSleeping = false
        currentFatigueLevel = 3
        currentBedtimeMessage = ""
        currentInsomniaMessages = []
        saveCurrentState()
        
        // 수면 목표 시간 초기화
        sleepGoal = 8.0
        
        print("🗑️ 모든 수면 기록 삭제 완료")
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
    
    // MARK: - Sleep Summary
    
    var lastSleepRecord: SleepRecord? {
        return sleepRecords.last
    }
    
    func addSleepReview(to record: SleepRecord, review: String) {
        if let index = sleepRecords.firstIndex(where: { $0.id == record.id }) {
            sleepRecords[index].sleepReview = review
            saveSleepRecords()
            print("📝 수면 후기 저장: \(review)")
        }
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