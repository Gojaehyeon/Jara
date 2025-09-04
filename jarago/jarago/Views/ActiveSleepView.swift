import SwiftUI

// 수면 중 화면
struct ActiveSleepView: View {
    @ObservedObject var viewModel: SleepViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // 자라 캐릭터 (달 모양)
            VStack(spacing: 20) {
                Image(systemName: "moon.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.isSleeping)
                
                VStack(spacing: 8) {
                    
                    if let bedtime = viewModel.currentBedtime {
                        SleepCountdownView(bedtime: bedtime, sleepGoal: viewModel.currentSleepGoal)
                    }
                }
                
                Text("앱을 다시 열면 자동으로 기상이 기록됩니다")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            // 수면 중 표시
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
        .padding(.horizontal, 24)
        .navigationTitle("수면 중")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("취소") {
                    viewModel.cancelSleep()
                    dismiss()
                }
                .foregroundColor(.red)
            }
        }
        .onAppear {
            viewModel.startSleep()
        }
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
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(formatRemainingTime(remainingTime))
                .font(.title2)
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

#Preview {
    ActiveSleepView(viewModel: SleepViewModel())
}
