import SwiftUI

struct PostView: View {
    var post: Post
    @ObservedObject var viewModel: InspirationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // ✅ Автор публикации
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading) {
                    Text(post.author)
                        .font(.headline)
                    Text(post.date.formatted())
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                
                // ✅ Кнопка подписки
                Button(action: { viewModel.toggleFollow(for: post) }) {
                    Text(viewModel.isFollowing(post) ? "Отписаться" : "Подписаться")
                        .font(.caption)
                        .padding(5)
                        .background(viewModel.isFollowing(post) ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
            }
            
            // ✅ Отображение аутфита
            if let outfit = post.outfit {
                OutfitCard(outfit: outfit)
            }

            // ✅ Кнопки взаимодействия
            HStack {
                Button(action: { viewModel.toggleLike(for: post) }) {
                    HStack {
                        Image(systemName: viewModel.isLiked(post) ? "heart.fill" : "heart")
                            .foregroundColor(viewModel.isLiked(post) ? .red : .black)
                        Text("\(post.likes)")
                    }
                }

                Button(action: { viewModel.addComment(to: post) }) {
                    Image(systemName: "bubble.left")
                    Text("\(post.comments.count)")
                }

                Spacer()

                // ✅ Кнопка "Скопировать аутфит"
                if let outfit = post.outfit {
                    Button(action: { viewModel.copyOutfit(outfit) }) {
                        Image(systemName: "square.on.square")
                        Text("Копировать аутфит")
                    }
                }
            }
            .font(.footnote)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

