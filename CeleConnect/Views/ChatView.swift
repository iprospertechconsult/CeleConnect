//
//  ChatView.swift
//  CeleConnect
//
//  Created by Deborah on 1/6/26.
//

import SwiftUI

struct ChatView: View {
    let match: Match
    @StateObject private var vm = ChatViewModel()

    // ✅ unwrap the optional id once
    private var matchId: String {
        match.id ?? ""
    }

    var body: some View {
        VStack {
            if matchId.isEmpty {
                Text("Missing match id.")
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 10) {
                            ForEach(vm.messages) { msg in
                                MessageBubble(message: msg)
                                    .id(msg.id ?? UUID().uuidString) // safe if id nil
                            }
                        }
                        .padding()
                    }
                    .onChange(of: vm.messages.count) { _, _ in
                        if let last = vm.messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id ?? "", anchor: .bottom)
                            }
                        }
                    }
                }

                HStack(spacing: 10) {
                    TextField("Message…", text: $vm.draft)
                        .textFieldStyle(.roundedBorder)

                    Button("Send") {
                        Task { await vm.send(matchId: matchId) } // ✅ pass string id
                    }
                    .disabled(vm.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
            }
        }
        .navigationTitle("Chat")
        .onAppear {
            guard !matchId.isEmpty else { return }
            vm.listen(matchId: matchId) // ✅ pass string id
        }
        .alert(
            "Error",
            isPresented: Binding(
                get: { vm.errorMessage != nil },
                set: { _ in vm.errorMessage = nil }
            )
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if isMine {
                Spacer()
                Text(message.text)
                    .padding(10)
                    .background(.blue.opacity(0.2))
                    .cornerRadius(12)
            } else {
                Text(message.text)
                    .padding(10)
                    .background(.gray.opacity(0.15))
                    .cornerRadius(12)
                Spacer()
            }
        }
    }

    private var isMine: Bool {
        FirebaseRefs.currentUID == message.fromUid
    }
}
