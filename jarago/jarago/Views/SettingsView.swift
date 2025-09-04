import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SleepViewModel
    @State private var sleepGoal: Double
    @State private var showingDeleteAlert = false
    
    init(viewModel: SleepViewModel) {
        self.viewModel = viewModel
        self._sleepGoal = State(initialValue: viewModel.currentSleepGoal)
    }
    
    var body: some View {
        NavigationView {
            List {
//                Section(header: Text("수면 설정")) {
//                    VStack(alignment: .leading, spacing: 12) {
//                        HStack {
//                            Text("수면 목표 시간")
//                                .font(.headline)
//                            Spacer()
//                            Text("\(Int(sleepGoal))시간")
//                                .font(.title3)
//                                .fontWeight(.semibold)
//                                .foregroundColor(.blue)
//                        }
//                        
//                        Slider(value: $sleepGoal, in: 6...12, step: 0.5)
//                            .accentColor(.blue)
//                        
//                        Text("목표 시간을 설정하면 자동으로 기상 알림이 설정됩니다")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                    }
//                    .padding(.vertical, 8)
//                }
                
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
                        showingDeleteAlert = true
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
            .confirmationDialog("모든 수면 기록 삭제", isPresented: $showingDeleteAlert, titleVisibility: .visible) {
                Button("삭제", role: .destructive) {
                    viewModel.deleteAllRecords()
                }
                Button("취소", role: .cancel) { }
            } message: {
                Text("이 작업은 되돌릴 수 없습니다. 모든 수면 기록과 설정이 영구적으로 삭제됩니다.")
            }
        }
    }
} 
