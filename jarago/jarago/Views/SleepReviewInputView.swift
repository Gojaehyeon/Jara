import SwiftUI

// 수면 후기 입력 뷰
struct SleepReviewInputView: View {
    let record: SleepRecord
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SleepViewModel
    @State private var sleepReview: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // 헤더
                VStack(spacing: 16) {
                    Image(systemName: "bed.double.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("오늘의 수면 후기")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .padding(.top, 20)
                
                // 수면 정보 요약
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("취침")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(record.formattedBedtime)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    VStack(spacing: 4) {
                        Text("기상")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(record.formattedWakeTime)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    VStack(spacing: 4) {
                        Text("수면 시간")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(record.formattedDuration)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 24)
                
                // 후기 입력
                VStack(spacing: 16) {
                    
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray5))
                            .frame(height: 120)
                        
                        if sleepReview.isEmpty {
                            Text("오늘 잠은 어떠셨나요?")
                                .foregroundColor(.secondary)
                                .padding(.top, 16)
                                .padding(.leading, 16)
                        }
                        
                        TextField("", text: $sleepReview, axis: .vertical)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .lineLimit(5...8)
                            .focused($isTextFieldFocused)
                    }
                }
                .padding(.horizontal, 24)
                
                // 버튼들
                VStack(spacing: 12) {
                    Button(action: {
                        // 후기를 기록에 저장
                        if !sleepReview.isEmpty {
                            viewModel.addSleepReview(to: record, review: sleepReview)
                        }
                        // 기록 탭으로 이동하고 디테일뷰 표시
                        NotificationCenter.default.post(name: NSNotification.Name("NavigateToRecordDetail"), object: record)
                        dismiss()
                    }) {
                        Text("완료")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        // 기록 탭으로 이동하고 디테일뷰 표시
                        NotificationCenter.default.post(name: NSNotification.Name("NavigateToRecordDetail"), object: record)
                        dismiss()
                    }) {
                        Text("건너뛰기")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                print("📝 SleepReviewInputView 표시됨 - 기록: \(record.formattedDuration)")
                isTextFieldFocused = true
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}

#Preview {
    SleepReviewInputView(
        record: SleepRecord(
            bedtime: Date().addingTimeInterval(-28800), // 8시간 전
            wakeTime: Date(),
            fatigueLevel: 4,
            bedtimeMessage: "오늘은 정말 피곤했어요.",
            insomniaMessages: [
                InsomniaMessage(message: "잠 못 드는 밤..뭘 하고 있나요?", isFromUser: false),
                InsomniaMessage(message: "그냥 생각이 많아서요")
            ]
        ),
        viewModel: SleepViewModel()
    )
}
