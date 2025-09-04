import Foundation

struct SleepRecord: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let bedtime: Date
    let wakeTime: Date
    let duration: TimeInterval
    
    init(bedtime: Date, wakeTime: Date) {
        self.date = Calendar.current.startOfDay(for: bedtime)
        self.bedtime = bedtime
        self.wakeTime = wakeTime
        self.duration = wakeTime.timeIntervalSince(bedtime)
    }
    
    var durationHours: Double {
        return duration / 3600.0
    }
    
    var formattedDuration: String {
        let hours = Int(durationHours)
        let minutes = Int((durationHours - Double(hours)) * 60)
        return "\(hours)시간 \(minutes)분"
    }
    
    var formattedBedtime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: bedtime)
    }
    
    var formattedWakeTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: wakeTime)
    }
} 