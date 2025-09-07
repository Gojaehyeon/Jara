import SwiftUI

// 수면 중 화면
struct ActiveSleepView: View {
    @ObservedObject var viewModel: SleepViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingInsomniaModal = false
    
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
            }
            
            Spacer()
            
            // 잠에 들지 못했어요 버튼
            Button(action: {
                showingInsomniaModal = true
            }) {
                Text("잠에 들지 못했어요")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .underline()
            }
            .padding(.bottom, -8)
            
            // 수면 종료 버튼 (항상 표시)
            Button(action: {
                viewModel.wakeUp()
            }) {
                HStack {
                    Image(systemName: "sun.max.fill")
                    Text("수면 종료")
                }
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color.orange)
                .cornerRadius(16)
            }
            
        }
        .padding(.horizontal, 24)
        .navigationTitle("수면 중")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("취소") {
                    viewModel.resetToInitialState()
                    // dismiss()는 resetToInitialState()에서 처리됨
                }
                .foregroundColor(.red)
            }
        }
        .onAppear {
            viewModel.startSleep()
        }
        .sheet(isPresented: $showingInsomniaModal) {
            InsomniaMessageView(viewModel: viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
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
        return wakeUpTime.timeIntervalSince(currentTime)
    }
    
    var isOvertime: Bool {
        return remainingTime <= 0
    }
    
    var overtimeMinutes: Int {
        return max(0, Int(-remainingTime) / 60)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            if isOvertime {
                Text("수면 시간 초과")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                Text("+\(overtimeMinutes)분")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            } else {
                Text("남은 수면 시간")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(formatRemainingTime(remainingTime))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
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
