import SwiftUI

struct CommentsView: View {
    @Binding var post: Post
    @State private var newComment: String = ""

    var body: some View {
        NavigationView {
            VStack {
                List(post.comments, id: \.self) { comment in
                    Text(comment)
                        .padding()
                }

                HStack {
                    TextField("Добавить комментарий...", text: $newComment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button("Отправить") {
                        if !newComment.isEmpty {
                            post.comments.append(newComment) 
                            newComment = ""
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Комментарии")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
