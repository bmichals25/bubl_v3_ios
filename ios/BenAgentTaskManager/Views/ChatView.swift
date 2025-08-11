import SwiftUI

struct ChatView: View {
    @EnvironmentObject private var chat: ChatViewModel
    @State private var input: String = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(chat.messages) { m in
                            HStack {
                                if m.role == .assistant { Spacer().frame(width: 0) }
                                Text(m.text)
                                    .padding(10)
                                    .background(m.role == .user ? Color.blue.opacity(0.15) : Color.gray.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                if m.role == .user { Spacer().frame(width: 0) }
                            }
                            .frame(maxWidth: .infinity, alignment: m.role == .user ? .trailing : .leading)
                        }
                    }
                    .padding()
                }
            }
            HStack {
                TextField("Type a message", text: $input)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button {
                    let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !text.isEmpty else { return }
                    input = ""
                    Task { await chat.send(text) }
                } label: { Image(systemName: "paperplane.fill") }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("AI Chat")
    }
}