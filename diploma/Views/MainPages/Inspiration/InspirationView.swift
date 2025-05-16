import SwiftUI

struct InspirationView: View {
    @StateObject private var viewModel = InspirationViewModel()
    @StateObject private var outfitViewModel = OutfitViewModel()

    @State private var showingCommentSheet = false
    @State private var selectedPostIndex: Int?
    @State private var showingCreatePostSheet = false
    @State private var selectedOutfit: OutfitResponse?

    @State private var commentViewModel: CommentsViewModel?

    var body: some View {
        VStack(spacing: 0) {
            searchBar

            if !viewModel.searchText.isEmpty {
                userSearchResults
            } else {
                postFeed
            }
        }
        .navigationTitle("Лента публикаций")
        .onAppear {
            viewModel.fetchPosts(reset: true)
        }
        .onChange(of: viewModel.searchText) { newValue in
            DispatchQueue.main.async {
                if newValue.isEmpty {
                    viewModel.fetchPosts(reset: true)
                } else {
                    viewModel.searchUsers()
                }
            }
        }
        .sheet(isPresented: $showingCreatePostSheet) {
            CreatePostView(
                posts: .constant(viewModel.postViewModels.map { $0.post }),
                outfitViewModel: outfitViewModel
            )
        }
        .sheet(isPresented: $showingCommentSheet) {
            if let commentVM = commentViewModel {
                CommentsView(viewModel: commentVM)
                    .navigationTitle("Комментарии")
                    .navigationBarTitleDisplayMode(.inline)
            } else {
                Text("Ошибка загрузки комментариев")
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding()
                    .navigationTitle("Комментарии")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .sheet(item: $selectedOutfit) { outfit in
            OutfitDetailPublicView(outfit: outfit)
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var searchBar: some View {
        TextField("Поиск пользователей...", text: $viewModel.searchText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
            .submitLabel(.search)
            .padding(.vertical, 8)
    }

    private var userSearchResults: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.searchResults) { user in
                    NavigationLink(
                        destination: OtherUserProfileView(userId: user.id)
                    ) {
                        HStack(spacing: 12) {
                            if let avatar = user.avatar {
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
                            VStack(alignment: .leading, spacing: 2) {
                                Text("@\(user.username)")
                                    .fontWeight(.semibold)
                                if let bio = user.bio {
                                    Text(bio)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.top, 8)
        }
        .transition(.opacity)
    }

    private var postFeed: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(Array(viewModel.postViewModels.enumerated()), id: \.offset) { index, postVM in
                        PostView(
                            viewModel: postVM,
                            onComment: {
                                selectedPostIndex = index
                                commentViewModel = CommentsViewModel(postId: postVM.post.id)
                                commentViewModel?.start()
                                showingCommentSheet = true
                            },
                            onTap: {
                                if let firstOutfitId = postVM.post.outfits.first {
                                    outfitViewModel.fetchOutfit(id: firstOutfitId) { result in
                                        switch result {
                                        case .success(let outfit):
                                            selectedOutfit = outfit
                                        case .failure(let error):
                                            print("Ошибка загрузки образа: \(error)")
                                        }
                                    }
                                }
                            }
                        )
                        .onAppear {
                            viewModel.loadMoreIfNeeded(currentPost: postVM.post)
                        }
                    }
                }
                .padding()
            }

            Divider()
                .padding(.top, 12)

            Button(action: {
                showingCreatePostSheet = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Добавить новый пост")
                }
                .font(.headline)
                .foregroundColor(.blue)
                .padding()
            }
        }
    }
}
