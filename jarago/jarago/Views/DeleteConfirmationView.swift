import SwiftUI

// 삭제 확인 바텀시트
struct DeleteConfirmationView: View {
    @ObservedObject var viewModel: SleepViewModel
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // 아이콘
            Image(systemName: "trash.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
                .padding(.top, 20)
            
            // 제목
            Text("모든 수면 기록을 삭제하시겠습니까?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
            
            // 설명
            Text("이 작업은 되돌릴 수 없습니다.\n모든 수면 기록과 설정이 영구적으로 삭제됩니다.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
            
            Spacer()
            
            // 버튼들
            VStack(spacing: 12) {
                // 삭제하기 버튼
                Button(action: {
                    viewModel.deleteAllRecords()
                    dismiss()
                    isPresented = false
                }) {
                    Text("삭제하기")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.red)
                        .cornerRadius(12)
                }
                
                // 취소 버튼
                Button(action: {
                    dismiss()
                }) {
                    Text("취소")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(.systemGray5))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    DeleteConfirmationView(
        viewModel: SleepViewModel(),
        isPresented: .constant(true)
    )
}
