import Foundation

struct UserSettings: Codable {
    var sleepGoal: Double // 시간 단위
    
    static let `default` = UserSettings(sleepGoal: 8.0)
} 