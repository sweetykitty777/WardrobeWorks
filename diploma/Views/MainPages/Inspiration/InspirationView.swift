import SwiftUI

struct InspirationView: View {
    @StateObject private var viewModel = InspirationViewModel()
    @StateObject private var outfitViewModel = OutfitViewModel()
    
    @State private var showingCommentSheet = false
    @State private var selectedPostIndex: Int?
    @State private var showingCreatePostSheet = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                TextField("Поиск пользователей...", text: $viewModel.searchText, onCommit: {
                    viewModel.searchUsers()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .submitLabel(.search)
                .padding(.vertical, 8)
                
                if !viewModel.searchText.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.searchResults) { user in
                                NavigationLink(destination: OtherUserProfileView(userId: user.id)) {
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
                    .onAppear {
                        viewModel.searchUsers()
                    }
                    .transition(.opacity)
                
                } else {
                    VStack(spacing: 0) {
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                ForEach(viewModel.postViewModels.indices, id: \.self) { index in
                                    let postVM = viewModel.postViewModels[index]
                                    PostView(viewModel: postVM) {
                                        selectedPostIndex = index
                                        showingCommentSheet = true
                                    }
                                        .onAppear {
                                            viewModel.loadMoreIfNeeded(currentPost: postVM.post)
                                        }
                                        .onTapGesture {
                                            selectedPostIndex = index
                                            showingCommentSheet = true
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
            .navigationTitle("Лента публикаций")
            .onAppear {
                viewModel.fetchPosts(reset: true)
            }
            .onChange(of: viewModel.searchText) { newValue in
                if newValue.isEmpty {
                    viewModel.fetchPosts(reset: true)
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
            if let idx = selectedPostIndex, idx < viewModel.postViewModels.count {
                NavigationView {
                    CommentsView(postId: viewModel.postViewModels[idx].post.id)
                        .navigationTitle("Комментарии")
                        .navigationBarTitleDisplayMode(.inline)
                }
            } else {
                Text("Ошибка загрузки комментариев")
                    .font(.headline)
                    .foregroundColor(.red)
            }
        }

    }
}
