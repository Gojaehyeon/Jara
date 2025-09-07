import SwiftUI

// 수면 기록 상세 정보 뷰
struct SleepRecordDetailView: View {
    let record: SleepRecord
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 기본 정보
                VStack(spacing: 16) {
                    Text("수면 기록")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack(spacing: 20) {
                        VStack(spacing: 8) {
                            Text("취침")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(record.formattedBedtime)
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        
                        VStack(spacing: 8) {
                            Text("기상")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(record.formattedWakeTime)
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        
                        VStack(spacing: 8) {
                            Text("수면 시간")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(record.formattedDuration)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)

                }
                .padding(20)
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                // 피곤함 수치
                VStack(spacing: 16) {
                    Text("피로도")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 8) {
                        ForEach(1...5, id: \.self) { level in
                            Circle()
                                .fill(level <= record.fatigueLevel ? Color.orange : Color.gray.opacity(0.3))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text("\(level)")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(level <= record.fatigueLevel ? .white : .gray)
                                )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(20)
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                // 자기 전 한마디
                if !record.bedtimeMessage.isEmpty {
                    VStack(spacing: 16) {
                        Text("자기 전 한마디")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(record.bedtimeMessage)
                            .font(.body)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                    }
                    .padding(20)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }
                
                // 수면 후기
                if !record.sleepReview.isEmpty {
                    VStack(spacing: 16) {
                        Text("수면 후기")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(record.sleepReview)
                            .font(.body)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                    }
                    .padding(20)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }
                
                // 불면 메시지들
                if !record.insomniaMessages.isEmpty {
                    VStack(spacing: 16) {
                        Text("로그")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 12) {
                            ForEach(Array(record.insomniaMessages.enumerated()), id: \.element.id) { index, message in
                                VStack(spacing: 4) {
                                    HStack {
                                        if message.isFromUser {
                                            Spacer()
                                            Text(message.message)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(Color.blue)
                                                .foregroundColor(.white)
                                                .cornerRadius(16)
                                                .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
                                        } else {
                                            Text(message.message)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(Color(.systemGray5))
                                                .foregroundColor(.primary)
                                                .cornerRadius(16)
                                                .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
                                            Spacer()
                                        }
                                    }
                                    
                                    // 시간 표시 (같은 분의 마지막 메시지에만)
                                    if isLastMessageInGroup(at: index, messages: record.insomniaMessages) {
                                        HStack {
                                            if message.isFromUser {
                                                Spacer()
                                                Text(formatMessageTime(message.timestamp))
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                                    .padding(.trailing, 8)
                                            } else {
                                                Text(formatMessageTime(message.timestamp))
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                                    .padding(.leading, 8)
                                                Spacer()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .navigationTitle(record.date.formatted(.dateTime.month().day()))
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Helper Functions
    
    private func formatMessageTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func isLastMessageInGroup(at index: Int, messages: [InsomniaMessage]) -> Bool {
        guard index < messages.count else { return true }
        
        let currentMessage = messages[index]
        let currentMinute = Calendar.current.component(.minute, from: currentMessage.timestamp)
        
        // 다음 메시지가 있고, 같은 분에 보낸 메시지가 있으면 그룹의 마지막이 아님
        if index + 1 < messages.count {
            let nextMessage = messages[index + 1]
            let nextMinute = Calendar.current.component(.minute, from: nextMessage.timestamp)
            
            if currentMinute == nextMinute {
                return false
            }
        }
        
        return true
    }
}

#Preview {
    NavigationView {
        SleepRecordDetailView(record: SleepRecord(
            bedtime: Date().addingTimeInterval(-28800), // 8시간 전
            wakeTime: Date(),
            fatigueLevel: 4,
            bedtimeMessage: "오늘은 정말 피곤했어요. 내일은 더 좋은 하루가 되길 바라요.",
            insomniaMessages: [
                InsomniaMessage(message: "잠 못 드는 밤..뭘 하고 있나요?", isFromUser: false, timestamp: Date().addingTimeInterval(-25200)), // 7시간 전
                InsomniaMessage(message: "그냥 생각이 많아서요", isFromUser: true, timestamp: Date().addingTimeInterval(-25200)), // 같은 시간
                InsomniaMessage(message: "걱정되는 일이 있나요?", isFromUser: false, timestamp: Date().addingTimeInterval(-25140)), // 1분 후
                InsomniaMessage(message: "아니요, 그냥 잠이 안 와요", isFromUser: true, timestamp: Date().addingTimeInterval(-25140)) // 같은 시간
            ],
            sleepReview: "오늘은 잠들기 어려웠지만 결국 잠들었어요."
        ))
    }
}
