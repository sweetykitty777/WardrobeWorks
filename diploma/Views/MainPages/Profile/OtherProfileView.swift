import SwiftUI

struct OtherUserProfileView: View {
    let userId: Int
    @StateObject private var viewModel = OtherUserProfileViewModel()
    @State private var showingCommentSheet = false
    @State private var selectedPostId: Int?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // MARK: — Avatar and Username
                VStack(spacing: 8) {
                    if let avatarURL = viewModel.user.avatar {
                        RemoteImageView(
                            urlString: avatarURL,
                            cornerRadius: 40,
                            width: 80,
                            height: 80
                        )
                    } else {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                    }

                    Text("@\(viewModel.user.username)")
                        .font(.title2)
                        .fontWeight(.semibold)

                    if let bio = viewModel.user.bio {
                        Text(bio)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding(.top)

                // MARK: — Follow / Unfollow Button
                Button(action: {
                    if viewModel.isFollowing {
                        viewModel.unfollow(followedId: userId)
                    } else {
                        viewModel.follow(followedId: userId)
                    }
                }) {
                    Text(viewModel.isFollowing ? "Отписаться" : "Подписаться")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            viewModel.isFollowing
                                ? Color.red.opacity(0.1)
                                : Color.blue.opacity(0.1)
                        )
                        .foregroundColor(viewModel.isFollowing ? .red : .blue)
                        .cornerRadius(8)
                }
                .disabled(viewModel.loadingFollowState)
                .padding(.horizontal)

                Divider()

                // MARK: — Публикации (новые слева)
                if !viewModel.posts.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Публикации")
                            .font(.headline)
                            .padding(.leading)
                            .padding(.top, 12)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(
                                    viewModel.posts
                                        .sorted { $0.createdAt > $1.createdAt },
                                    id: \.id
                                ) { post in
                                    let vm = PostViewModel(post: post)
                                    PostView(viewModel: vm) {
                                        selectedPostId = post.id
                                        showingCommentSheet = true
                                    }
                                }
                            }
                            .padding(.leading)
                            .padding(.top, 12)
                        }
                    }
                }

                // MARK: — Публичные вещи
                if !viewModel.publicItems.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Публичные вещи")
                            .font(.headline)
                            .padding(.leading)
                            .padding(.top, 12)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.publicItems, id: \.id) { item in
                                    ClothItemProfileViewPublic(item: item)
                                }
                            }
                            .padding(.leading)
                            .padding(.top, 12)
                        }
                    }
                }

                // MARK: — Публичные аутфиты
                if !viewModel.publicOutfits.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Публичные аутфиты")
                            .font(.headline)
                            .padding(.leading)
                            .padding(.top, 12)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.publicOutfits, id: \.id) { outfit in
                                    OutfitCard(outfit: outfit)
                                }
                            }
                            .padding(.leading)
                            .padding(.top, 12)
                        }
                    }
                }

                // MARK: — Публичные лукбуки
                // MARK: — Публичные лукбуки
                if !viewModel.publicLookbooks.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Публичные лукбуки")
                            .font(.headline)
                            .padding(.leading)
                            .padding(.top, 12)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.publicLookbooks, id: \.id) { lookbook in
                                    NavigationLink {
                                        LookbookDetailView(lookbook: lookbook, wardrobeId: nil)
                                    } label: {
                                        ProfileLookbookItemView(
                                            title: lookbook.name,
                                            subtitle: lookbook.description
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.leading)
                            .padding(.top, 12)
                        }
                    }
                }

            }
            .padding(.horizontal)
        }
        .navigationTitle("Профиль")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadProfile(for: userId)
        }
        .sheet(isPresented: $showingCommentSheet) {
            if let postId = selectedPostId {
                CommentsView(postId: postId)
            }
        }
    }
}
