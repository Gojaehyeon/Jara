import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SleepViewModel
    @State private var sleepGoal: Double
    
    init(viewModel: SleepViewModel) {
        self.viewModel = viewModel
        self._sleepGoal = State(initialValue: viewModel.currentSleepGoal)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("수면 설정")) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("수면 목표 시간")
                                .font(.headline)
                            Spacer()
                            Text("\(Int(sleepGoal))시간")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                        
                        Slider(value: $sleepGoal, in: 6...12, step: 0.5)
                            .accentColor(.blue)
                        
                        Text("목표 시간을 설정하면 자동으로 기상 알림이 설정됩니다")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("앱 정보")) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("버전")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("자라와 함께하는 수면 루틴")
                        Spacer()
                    }
                }
                
                Section(header: Text("데이터 관리")) {
                    Button(action: {
                        // 데이터 초기화 확인 다이얼로그
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("모든 수면 기록 삭제")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.large)
            .onChange(of: sleepGoal) { _, newValue in
                viewModel.updateSleepGoal(newValue)
            }
        }
    }
} 