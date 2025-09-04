import Foundation

struct InsomniaMessage: Identifiable, Codable {
    var id = UUID()
    let message: String
    let timestamp: Date
    let isFromUser: Bool
    
    init(message: String, isFromUser: Bool = true, timestamp: Date = Date()) {
        self.message = message
        self.timestamp = timestamp
        self.isFromUser = isFromUser
    }
}

struct SleepRecord: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let bedtime: Date
    let wakeTime: Date
    let duration: TimeInterval
    let fatigueLevel: Int // 1-5 피곤함 정도
    let bedtimeMessage: String // 자기 전 한마디
    let insomniaMessages: [InsomniaMessage] // 잠에 들지 못했을 때의 메시지들
    var sleepReview: String // 수면 후기
    
    init(bedtime: Date, wakeTime: Date, fatigueLevel: Int = 3, bedtimeMessage: String = "", insomniaMessages: [InsomniaMessage] = [], sleepReview: String = "") {
        self.date = Calendar.current.startOfDay(for: bedtime)
        self.bedtime = bedtime
        self.wakeTime = wakeTime
        self.duration = wakeTime.timeIntervalSince(bedtime)
        self.fatigueLevel = fatigueLevel
        self.bedtimeMessage = bedtimeMessage
        self.insomniaMessages = insomniaMessages
        self.sleepReview = sleepReview
    }
    
    var durationHours: Double {
        return duration / 3600.0
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        return formatter.string(from: date)
    }
    
    var formattedDuration: String {
        let hours = Int(durationHours)
        let minutes = Int((durationHours - Double(hours)) * 60)
        return "\(hours)시간 \(minutes)분"
    }
    
    var formattedBedtime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: bedtime)
    }
    
    var formattedWakeTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: wakeTime)
    }
} 