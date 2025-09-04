import SwiftUI

struct SleepView: View {
    @ObservedObject var viewModel: SleepViewModel
    @State private var selectedHours: Int = 8
    @State private var selectedMinutes: Int = 0
    @State private var showingSleepScreen = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
//                Spacer()
                
                // 자라 캐릭터
//                VStack(spacing: 20) {
//                    Image(systemName: "sun.max.fill")
//                        .font(.system(size: 80))
//                        .foregroundColor(.orange)
//                        .scaleEffect(1.0)
//                    
//                    Text("자라와 함께\n수면 시간을 설정해요!")
//                        .font(.title2)
//                        .fontWeight(.medium)
//                        .multilineTextAlignment(.center)
//                        .foregroundColor(.primary)
//                }
//                
//                Spacer()
                
                // 시간 선택 UI
                VStack(spacing: 24) {
                    Text("수면 목표 시간")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding()
                    
                    HStack(spacing: 20) {
                        // 시간 선택
                        VStack(spacing: 12) {
                            Text("시간")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Picker("Hours", selection: $selectedHours) {
                                ForEach(0...10, id: \.self) { hour in
                                    Text("\(hour)").tag(hour)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 120, height: 120)
                            .clipped()
                        }
                        
                        // 분 선택
                        VStack(spacing: 12) {
                            Text("분")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Picker("Minutes", selection: $selectedMinutes) {
                                ForEach(0...59, id: \.self) { minute in
                                    if minute % 5 == 0 {
                                        Text("\(minute)").tag(minute)
                                    }
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 120, height: 120)
                            .clipped()
                        }
                    }
                    .frame(width: 300)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }
                
                Spacer()
                
                // 수면 시작 버튼
                Button(action: {
                    let totalHours = Double(selectedHours) + Double(selectedMinutes) / 60.0
                    viewModel.updateSleepGoal(totalHours)
                    showingSleepScreen = true
                }) {
                    HStack {
                        Image(systemName: "bed.double.fill")
                        Text("수면 시작하기")
                    }
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.blue)
                    .cornerRadius(16)
                    .padding(.bottom, 24)
                }
                .disabled(selectedHours == 0 && selectedMinutes == 0)
                .opacity(selectedHours == 0 && selectedMinutes == 0 ? 0.5 : 1.0)
                
            }
            .padding(.horizontal, 24)
//            .navigationTitle("취침")
//            .navigationBarTitleDisplayMode(.large)
            .fullScreenCover(isPresented: $showingSleepScreen) {
                ActiveSleepView(viewModel: viewModel)
            }
        }
    }
}

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
                    Text("잘 자요... 💤")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
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
            
            // 수면 목표 표시
            VStack(spacing: 8) {
                Text("수면 목표")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(Int(viewModel.currentSleepGoal))시간 \(Int((viewModel.currentSleepGoal - Double(Int(viewModel.currentSleepGoal))) * 60))분")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
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
            
            Spacer()
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

#Preview {
    SleepView(viewModel: SleepViewModel())
}
