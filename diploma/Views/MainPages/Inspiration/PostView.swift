import SwiftUI

struct PostView: View {
    @Binding var post: Post
    @State private var showOutfitDetail = false
    @State private var showComments = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            if let imageName = post.outfit.imageName, let image = UIImage(named: imageName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .onTapGesture {
                        showOutfitDetail = true
                    }
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .foregroundColor(.gray)
            }

            Text(post.outfit.name)
                .font(.headline)
                .padding(.horizontal)

            if let description = post.description {
                HStack(alignment: .top) {
                    Text(post.author + ":")
                        .font(.headline)
                        .foregroundColor(.black)

                    Text(description)
                        .font(.body)
                        .foregroundColor(.black)
                        .lineLimit(nil)
                }
                .padding(.horizontal)
            }

            HStack {
                
                Button(action: {
                    post.likes += 1
                }) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("\(post.likes)")
                    }
                }

                Spacer()


                Button(action: {
                    showComments = true
                }) {
                    HStack {
                        Image(systemName: "message.fill")
                            .foregroundColor(.blue)
                        Text("\(post.comments.count)")
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(radius: 3)
        .sheet(isPresented: $showOutfitDetail) {
            OutfitDetailView(outfit: post.outfit)
        }
        .sheet(isPresented: $showComments) {
            CommentsView(post: $post)
        }
    }
}
