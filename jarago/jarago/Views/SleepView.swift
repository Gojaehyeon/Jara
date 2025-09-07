import SwiftUI

struct SleepView: View {
    @ObservedObject var viewModel: SleepViewModel
    @State private var selectedHours: Int = 8
    @State private var selectedMinutes: Int = 0
    @State private var showingSleepScreen = false
    @State private var showingInputScreen = false
    
    var body: some View {
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
                    Text("수면 기록하기")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.top, 24)
                    
                    // 기상 시간 표시
                    Text("\(Date().addingTimeInterval(Double(selectedHours) * 3600 + Double(selectedMinutes) * 60).formatted(date: .omitted, time: .shortened))에 일어나게 돼요.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
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
                                    if minute % 5 == 0 || minute == 1 {
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
                    showingInputScreen = true
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
            .sheet(isPresented: $showingInputScreen) {
                SleepInputView(viewModel: viewModel, showingSleepScreen: $showingSleepScreen)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .fullScreenCover(isPresented: $showingSleepScreen) {
                ActiveSleepView(viewModel: viewModel)
            }
            .onAppear {
                // 수면 중인 상태라면 ActiveSleepView로 이동
                if viewModel.isSleeping {
                    showingSleepScreen = true
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DismissActiveSleepView"))) { _ in
                print("📱 ActiveSleepView 닫기 알림 받음")
                showingSleepScreen = false
            }
    }
}

#Preview {
    SleepView(viewModel: SleepViewModel())
}
