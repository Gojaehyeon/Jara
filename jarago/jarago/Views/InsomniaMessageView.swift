import SwiftUI

// iMessage 스타일 불면 메시지 모달
struct InsomniaMessageView: View {
    @ObservedObject var viewModel: SleepViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var messageText = ""
    @State private var showingSendAnimation = false
    @State private var showingWelcomeMessage = false
    @State private var welcomeMessageTimestamp = Date()
    @State private var hasShownWelcomeMessage = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // 메시지 목록
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        // 환영 메시지
                        if showingWelcomeMessage {
                            MessageBubble(
                                message: InsomniaMessage(message: "잠 못 드는 밤..뭘 하고 있나요?", isFromUser: false, timestamp: welcomeMessageTimestamp),
                                isLastInGroup: true
                            )
                            .transition(.opacity)
                        }
                        
                        ForEach(Array(viewModel.currentInsomniaMessages.enumerated()), id: \.element.id) { index, message in
                            let isLastInGroup = isLastMessageInGroup(at: index)
                            MessageBubble(message: message, isLastInGroup: isLastInGroup)
                        }
                        
                        if showingSendAnimation {
                            MessageBubble(message: InsomniaMessage(message: messageText), isLastInGroup: true)
                                .transition(.opacity)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .padding(.top, 16)
                }
                .onChange(of: viewModel.currentInsomniaMessages.count) { _, _ in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(viewModel.currentInsomniaMessages.last?.id, anchor: .bottom)
                    }
                }
            }
            
            // 메시지 입력 영역
            VStack(spacing: 0) {
                Divider()
                
                HStack(spacing: 12) {
                    TextField("메시지를 입력하세요", text: $messageText, axis: .horizontal)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray5))
                        .cornerRadius(25)
                        .focused($isTextFieldFocused)
                        .lineLimit(1...4)
                        .onSubmit {
                            sendMessage()
                        }
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(messageText.isEmpty ? .gray : .blue)
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
            }
        }
        .onAppear {
            isTextFieldFocused = true
            welcomeMessageTimestamp = Date()
            
            // 첫 번째 열 때만 환영 메시지 표시
            if !hasShownWelcomeMessage {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingWelcomeMessage = true
                }
                hasShownWelcomeMessage = true
            }
        }
    }
    
    private func isLastMessageInGroup(at index: Int) -> Bool {
        let messages = viewModel.currentInsomniaMessages
        guard index < messages.count else { return true }
        
        let currentMessage = messages[index]
        let currentMinute = Calendar.current.component(.minute, from: currentMessage.timestamp)
        
        // 다음 메시지가 있고, 같은 분에 보낸 메시지가 있으면 그룹의 마지막이 아님
        if index + 1 < messages.count {
            let nextMessage = messages[index + 1]
            let nextMinute = Calendar.current.component(.minute, from: nextMessage.timestamp)
            
            if currentMinute == nextMinute {
                return false
            }
        }
        
        return true
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let message = messageText
        messageText = ""
        
        // 수면 취소 키워드 체크
        if message.lowercased().contains("수면 취소") || message.lowercased().contains("취소") {
            print("🔴 취소 메시지 감지: \(message)")
            viewModel.resetToInitialState()
            // dismiss()는 resetToInitialState()에서 처리됨
            return
        }
        
        // 보내는 애니메이션
        withAnimation(.easeInOut(duration: 0.3)) {
            showingSendAnimation = true
        }
        
        // 잠시 후 메시지 추가
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            viewModel.addInsomniaMessage(message)
            
            withAnimation(.easeInOut(duration: 0.3)) {
                showingSendAnimation = false
            }
        }
    }
}

// 메시지 버블
struct MessageBubble: View {
    let message: InsomniaMessage
    let isLastInGroup: Bool
    
    var body: some View {
        VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
            HStack {
                if message.isFromUser {
                    Spacer()
                    
                    Text(message.message)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(18)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
                } else {
                    Text(message.message)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(18)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
                    
                    Spacer()
                }
            }
            
            // 시간 표시 (그룹의 마지막 메시지에만)
            if isLastInGroup {
                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    InsomniaMessageView(viewModel: SleepViewModel())
}
