import SwiftUI

// 오늘의 수면 후기 입력 뷰
struct TodaySleepSummaryView: View {
    let record: SleepRecord
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SleepViewModel
    @State private var sleepReview: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 헤더
                    VStack(spacing: 16) {
                        Image(systemName: "bed.double.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("오늘의 수면 기록")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(record.date.formatted(.dateTime.month().day()))
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // 기본 정보 카드
                    VStack(spacing: 20) {
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
                    }
                    .padding(20)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    
                    // 피곤함 수치
                    VStack(spacing: 16) {
                        Text("피곤함 정도")
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
                        .frame(maxWidth: .infinity, alignment: .leading)
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
                    
                    // 자라와의 대화
                    if !record.insomniaMessages.isEmpty {
                        VStack(spacing: 16) {
                            Text("자라와의 대화")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 12) {
                                ForEach(record.insomniaMessages) { message in
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
                                }
                            }
                        }
                        .padding(20)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                    }
                    
                    // 수면 후기 입력
                    VStack(spacing: 16) {
                        Text("오늘 잠에 대한 후기를 남겨주세요")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
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
                    .padding(20)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    
                    // 완료 버튼
                    Button(action: {
                        // 후기를 기록에 저장
                        if !sleepReview.isEmpty {
                            viewModel.addSleepReview(to: record, review: sleepReview)
                        }
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
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .navigationTitle("수면 기록")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                isTextFieldFocused = true
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}

#Preview {
    TodaySleepSummaryView(
        record: SleepRecord(
            bedtime: Date().addingTimeInterval(-28800), // 8시간 전
            wakeTime: Date(),
            fatigueLevel: 4,
            bedtimeMessage: "오늘은 정말 피곤했어요. 내일은 더 좋은 하루가 되길 바라요.",
            insomniaMessages: [
                InsomniaMessage(message: "잠 못 드는 밤..뭘 하고 있나요?", isFromUser: false),
                InsomniaMessage(message: "그냥 생각이 많아서요"),
                InsomniaMessage(message: "걱정되는 일이 있나요?")
            ]
        ),
        viewModel: SleepViewModel()
    )
}
