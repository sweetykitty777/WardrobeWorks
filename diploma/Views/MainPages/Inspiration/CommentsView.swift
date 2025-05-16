import SwiftUI

struct CommentsView: View {
    @ObservedObject var viewModel: CommentsViewModel
    let maxCharacters = 200

    @FocusState private var isInputFocused: Bool
    @State private var showAlert = false

    var body: some View {
        VStack {
            if viewModel.isLoading || viewModel.currentUserId == nil {
                ProgressView("Загрузка…")
                    .padding()
            } else {
                List {
                    ForEach(viewModel.comments) { comment in
                        HStack(alignment: .top, spacing: 12) {
                            if let avatar = comment.user.avatar {
                                RemoteImageView(
                                    urlString: avatar,
                                    cornerRadius: 20,
                                    width: 40,
                                    height: 40
                                )
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.gray)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("@\(comment.user.username)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text(comment.text)
                                    .font(.body)
                                Text(formattedTime(from: comment.createdAt))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            if let currentUserId = viewModel.currentUserId,
                               currentUserId == comment.user.id {
                                Button(role: .destructive) {
                                    viewModel.deleteComment(comment.id)
                                } label: {
                                    Label("Удалить", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    TextField("Добавить комментарий…", text: Binding(
                        get: { viewModel.newCommentText },
                        set: { newValue in
                            if newValue.count <= maxCharacters {
                                viewModel.newCommentText = newValue
                            } else {
                                viewModel.newCommentText = String(newValue.prefix(maxCharacters))
                            }
                        })
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isInputFocused)

                    Button("Отправить") {
                        let trimmed = viewModel.newCommentText.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmed.isEmpty || trimmed.count > maxCharacters {
                            showAlert = true
                        } else {
                            viewModel.addComment()
                            isInputFocused = false
                        }
                    }
                    .disabled(viewModel.newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                HStack {
                    Spacer()
                    Text("\(viewModel.newCommentText.count)/\(maxCharacters)")
                        .font(.caption)
                        .foregroundColor(viewModel.newCommentText.count >= maxCharacters ? .red : .gray)
                }
            }
            .padding()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                viewModel.start()
                isInputFocused = true
            }
        }
        .alert("Пожалуйста, введите комментарий от 1 до \(maxCharacters) символов", isPresented: $showAlert) {
            Button("Ок", role: .cancel) { }
        }
    }

    private func formattedTime(from isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = formatter.date(from: isoString) ??
                         ISO8601DateFormatter().date(from: isoString) else {
            return "—"
        }

        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "ru_RU")
        displayFormatter.dateFormat = "d MMM в HH:mm"

        return displayFormatter.string(from: date)
    }
}
