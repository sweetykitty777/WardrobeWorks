import SwiftUI

struct PostView: View {
    @ObservedObject var viewModel: PostViewModel
    var onComment: () -> Void
    var onTap: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let imageUrlString = viewModel.post.images.first {
                CachedImageView(
                    urlString: imageUrlString,
                    width: UIScreen.main.bounds.width * 0.9,
                    height: 300
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                .frame(maxWidth: .infinity, alignment: .center)
            }

            if let caption = viewModel.post.text {
                HStack(alignment: .top, spacing: 4) {
                    NavigationLink(
                        destination: OtherUserProfileView(userId: viewModel.post.user)
                    ) {
                        Text("@\(viewModel.username)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    Text(caption)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }


            HStack(spacing: 24) {
                Button(action: { viewModel.didTapLike() }) {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                        Text("\(viewModel.likeCount)")
                    }
                    .font(.system(size: 20))
                    .foregroundColor(.pink)
                }

                Button(action: onComment) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
    }
}
