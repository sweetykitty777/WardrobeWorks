import SwiftUI

struct InspirationView: View {
    @StateObject private var viewModel = InspirationViewModel()
    @State private var showingCommentSheet: Bool = false
    @State private var selectedPostIndex: Int?
    @State private var showingCreatePostSheet: Bool = false
    @State private var showOnlyFollowing: Bool = false

    let followingAuthors: Set<String> = MockData.followingAuthors // Список подписок

    var filteredPosts: [Post] {
        showOnlyFollowing ? viewModel.posts.filter { followingAuthors.contains($0.author) } : viewModel.posts
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                HStack {
                    Picker("Источник", selection: $showOnlyFollowing) {
                        Text("Все").tag(false)
                        Text("Подписки").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    Spacer()
                    Button(action: {
                        showingCreatePostSheet = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .padding(8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                }
                .padding(.horizontal)

                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(filteredPosts.indices, id: \..self) { index in
                            PostView(post: $viewModel.posts[index])
                                .onTapGesture {
                                    selectedPostIndex = index
                                    showingCommentSheet = true
                                }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Лента публикаций")
        }
        .sheet(isPresented: $showingCommentSheet) {
            if let index = selectedPostIndex {
                CommentsView(post: $viewModel.posts[index])
            }
        }
        .sheet(isPresented: $showingCreatePostSheet) {
            CreatePostView(posts: $viewModel.posts)
        }
    }
}
