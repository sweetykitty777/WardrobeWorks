// CommentsView.swift
import SwiftUI

struct CommentsView: View {
    @StateObject private var viewModel: CommentsViewModel

    init(postId: Int) {
        _viewModel = StateObject(wrappedValue: CommentsViewModel(postId: postId))
    }

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Загрузка…")
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
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
                                    Text(comment.createdAt)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Button(role: .destructive) {
                                    viewModel.deleteComment(comment.id)
                                } label: {
                                    Image(systemName: "trash")
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
            }

            Divider()

            HStack {
                TextField("Добавить комментарий…", text: $viewModel.newCommentText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Отправить") {
                    viewModel.addComment()
                }
                .disabled(viewModel.newCommentText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
        }
    }
}
