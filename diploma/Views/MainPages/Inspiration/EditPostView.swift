import SwiftUI

struct EditPostView: View {
    let post: Post
    @ObservedObject var profileViewModel: UserProfileViewModel

    @Environment(\.dismiss) var dismiss
    @State private var text: String
    @State private var isSaving = false

    init(post: Post, profileViewModel: UserProfileViewModel) {
        self.post = post
        self.profileViewModel = profileViewModel
        _text = State(initialValue: post.text ?? "")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Редактировать пост")
                .font(.headline)

            VStack(alignment: .leading, spacing: 4) {
                TextEditor(text: Binding(
                    get: { self.text },
                    set: { newValue in
                        if newValue.count <= InputLimits.postTextMaxLength {
                            self.text = newValue
                        } else {
                            self.text = String(newValue.prefix(InputLimits.postTextMaxLength))
                        }
                    }
                ))
                .frame(height: 200)
                .padding(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3))
                )

                HStack {
                    Spacer()
                    Text("\(text.count)/\(InputLimits.postTextMaxLength)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Button(isSaving ? "Сохранение..." : "Сохранить") {
                isSaving = true
                profileViewModel.editPostText(postId: post.id, newText: text) { result in
                    isSaving = false
                    if case .success = result {
                        dismiss()
                    } else {
                        // optionally show an error
                    }
                }
            }
            .disabled(isSaving)
            .buttonStyle(.borderedProminent)
            .padding(.top)

            Spacer()
        }
        .padding()
    }
}
