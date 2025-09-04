import SwiftUI

// 수면 입력 화면
struct SleepInputView: View {
    @ObservedObject var viewModel: SleepViewModel
    @Binding var showingSleepScreen: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var fatigueLevel: Int = 3
    @State private var bedtimeMessage: String = ""
    
    var body: some View {
        VStack(spacing: 30) {
            
            VStack(spacing: 24) {
                // 피곤함 정도
                VStack(spacing: 16) {
                    Text("지금 얼마나 피곤한가요?")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    CustomFatigueSlider(value: $fatigueLevel)
                }
                
                // 자기 전 한마디
                VStack(spacing: 16) {
                    Text("자기 전 한마디를 기록해주세요")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    TextField("오늘은 바로 잠에 들 수 있기를 바라요.", text: $bedtimeMessage, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                        .frame(height: 100)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
            
            Spacer()
            
            // 수면 시작하기 버튼
            Button(action: {
                viewModel.currentFatigueLevel = fatigueLevel
                viewModel.currentBedtimeMessage = bedtimeMessage
                showingSleepScreen = true
                dismiss()
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
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}

// 커스텀 피곤함 슬라이더
struct CustomFatigueSlider: View {
    @Binding var value: Int
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("활기 넘침")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("매우 피곤")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 18)
            
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { level in
                    Button(action: {
                        value = level
                    }) {
                        VStack(spacing: 4) {
                            Text("\(level)")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(value >= level ? .white : .gray)
                        }
                        .frame(width: 50, height: 50)
                        .background(
                            Circle()
                                .fill(value >= level ? Color.orange : Color.gray.opacity(0.3))
                        )
                    }
                }
            }
            
            Text("피곤함 정도: \(value)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.orange)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

#Preview {
    SleepInputView(
        viewModel: SleepViewModel(),
        showingSleepScreen: .constant(false)
    )
}
