import SwiftUI

struct OtherUserProfileView: View {
    let userId: Int
    @StateObject private var viewModel = OtherUserProfileViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingCommentSheet = false
    @State private var commentViewModel: CommentsViewModel?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

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
                        .background(viewModel.isFollowing ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
                        .foregroundColor(viewModel.isFollowing ? .red : .blue)
                        .cornerRadius(8)
                }
                .disabled(viewModel.loadingFollowState)
                .padding(.horizontal)

                Divider()

                // MARK: — Публикации
                if !viewModel.posts.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Публикации")
                            .font(.headline)
                            .padding(.leading)
                            .padding(.top, 12)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.posts.sorted(by: { $0.createdAt > $1.createdAt }), id: \.id) { post in
                                    let vm = PostViewModel(post: post)
                                    PostView(viewModel: vm) {
                                        commentViewModel = CommentsViewModel(postId: post.id)
                                        showingCommentSheet = true
                                    }
                                }
                            }
                            .padding(.leading)
                            .padding(.top, 12)
                        }
                    }
                }

                if !viewModel.publicItems.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Публичные вещи")
                            .font(.headline)
                            .padding(.leading)
                            .padding(.top, 12)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.publicItems, id: \.id) { cloth in
                                    NavigationLink(value: PublicClothRoute(item: cloth)) {
                                        ClothItemProfileView(item: cloth)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.leading)
                            .padding(.top, 12)
                        }
                    }
                }

                if !viewModel.publicOutfits.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Публичные аутфиты")
                            .font(.headline)
                            .padding(.leading)
                            .padding(.top, 12)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.publicOutfits, id: \.id) { outfit in
                                    NavigationLink(value: PublicOutfitRoute(outfit: outfit)) {
                                        OutfitCardView(outfit: outfit)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.leading)
                            .padding(.top, 12)
                        }
                    }
                }

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
                                    NavigationLink(value: PublicLookbookRoute(lookbook: lookbook)) {
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

                // MARK: — Ничего нет
                if viewModel.posts.isEmpty &&
                    viewModel.publicItems.isEmpty &&
                    viewModel.publicOutfits.isEmpty &&
                    viewModel.publicLookbooks.isEmpty {
                    VStack {
                        Text("Пока ничего нет")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 40)
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Профиль")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.blue)
                }
            }
        }
        .onAppear {
            viewModel.loadProfile(for: userId)
        }
        .sheet(isPresented: $showingCommentSheet) {
            if let vm = commentViewModel {
                NavigationStack {
                    CommentsView(viewModel: vm)
                        .navigationTitle("Комментарии")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}
