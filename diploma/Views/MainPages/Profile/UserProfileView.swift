import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = UserProfileViewModel()

    @State private var isEditing = false
    @State private var showFollowers = false
    @State private var showFollowings = false

    // MARK: — Для комментариев
    @State private var showingCommentSheet = false
    @State private var selectedPostId: Int?

    @StateObject private var followersVM = FollowListViewModel()
    @StateObject private var followingsVM = FollowListViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // MARK: — Avatar and user info
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
                        }
                    }
                    .padding(.top)

                    // MARK: — Followers / Followings
                    HStack(spacing: 40) {
                        VStack {
                            Text("\(followersVM.users.count)")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("Подписчики")
                                .font(.caption)
                        }
                        .onTapGesture {
                            followersVM.fetchFollowers()
                            showFollowers = true
                        }

                        VStack {
                            Text("\(followingsVM.users.count)")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("Подписки")
                                .font(.caption)
                        }
                        .onTapGesture {
                            followingsVM.fetchFollowings()
                            showFollowings = true
                        }
                    }

                    Divider()

                    // MARK: — Public Posts (новые слева)
                    VStack(alignment: .leading) {
                        Text("Публикации")
                            .font(.headline)
                            .padding(.leading)
                            .padding(.top, 5)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.posts.sorted { $0.createdAt > $1.createdAt }, id: \.id) { post in
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
                    .padding(.top)

                    // MARK: — Public Items
                    VStack(alignment: .leading) {
                        Text("Публичные вещи")
                            .font(.headline)
                            .padding(.leading)
                            .padding(.top, 5)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.publicItems, id: \.id) { item in
                                    ClothItemProfileView(item: item)
                                }
                            }
                            .padding(.leading)
                            .padding(.top, 12)
                        }
                    }
                    .padding(.top)

                    // MARK: — Public Outfits
                    VStack(alignment: .leading) {
                        Text("Публичные аутфиты")
                            .font(.headline)
                            .padding(.leading)
                            .padding(.top, 5)

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
                    .padding(.top)

                    // MARK: — Public Lookbooks
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Публичные лукбуки")
                            .font(.headline)
                            .padding(.leading)
                            .padding(.top, 5)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.publicLookbooks, id: \.id) { lookbook in
                                    NavigationLink {
                                        // Здесь ваш экран деталей лукбука
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
                    .padding(.top)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button { isEditing = true } label: {
                            Image(systemName: "pencil")
                        }
                        Button { authViewModel.logout() } label: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                        }
                        .accessibilityLabel("Выйти")
                    }
                }
            }
            .onAppear {
                viewModel.loadUserProfile()
                // Предварительно загрузим списки
                followersVM.fetchFollowers()
                followingsVM.fetchFollowings()
            }
            .sheet(isPresented: $isEditing) {
                EditProfileView(viewModel: viewModel)
            }
            .sheet(isPresented: $showFollowers) {
                NavigationView {
                    FollowListView(viewModel: followersVM, title: "Подписчики")
                }
            }
            .sheet(isPresented: $showFollowings) {
                NavigationView {
                    FollowingListView(viewModel: followingsVM, title: "Подписки")
                }
            }
            .sheet(isPresented: $showingCommentSheet) {
                if let postId = selectedPostId {
                    CommentsView(postId: postId)
                }
            }
        }
    }
}

