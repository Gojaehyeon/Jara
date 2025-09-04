import SwiftUI

struct SleepView: View {
    @ObservedObject var viewModel: SleepViewModel
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // 자라 캐릭터
            VStack(spacing: 20) {
                Image(systemName: viewModel.isSleeping ? "moon.fill" : "sun.max.fill")
                    .font(.system(size: 80))
                    .foregroundColor(viewModel.isSleeping ? .blue : .orange)
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.isSleeping)
                
                if viewModel.isSleeping {
                    VStack(spacing: 8) {
                        Text("잘 자요... 💤")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        if let bedtime = viewModel.currentBedtime {
                            SleepCountdownView(bedtime: bedtime, sleepGoal: viewModel.currentSleepGoal)
                        }
                    }
                } else {
                    Text("자라와 함께\n수면 루틴을 만들어요!")
                        .font(.title2)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                }
                
                if viewModel.isSleeping {
                    Text("앱을 다시 열면 자동으로 기상이 기록됩니다")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            
            Spacer()
            
            // 수면 목표 표시
            VStack(spacing: 8) {
                Text("수면 목표")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(Int(viewModel.currentSleepGoal))시간")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // 취침 버튼
            if !viewModel.isSleeping {
                Button(action: {
                    viewModel.startSleep()
                }) {
                    HStack {
                        Image(systemName: "bed.double.fill")
                        Text("취침 기록")
                    }
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.blue)
                    .cornerRadius(16)
                }
            } else {
                // 수면 중일 때 비활성화된 버튼
                HStack {
                    Image(systemName: "moon.fill")
                    Text("수면 중...")
                }
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color.gray)
                .cornerRadius(16)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .navigationTitle("취침")
        .navigationBarTitleDisplayMode(.large)
    }
}

// 수면 카운트다운 뷰
struct SleepCountdownView: View {
    let bedtime: Date
    let sleepGoal: Double
    @State private var currentTime = Date()
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var remainingTime: TimeInterval {
        let wakeUpTime = bedtime.addingTimeInterval(sleepGoal * 3600)
        return max(0, wakeUpTime.timeIntervalSince(currentTime))
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text("남은 수면 시간")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(formatRemainingTime(remainingTime))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.blue)
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }
    
    private func formatRemainingTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)시간 \(minutes)분"
        } else {
            return "\(minutes)분"
        }
    }
} 