import SwiftUI

struct InspirationView: View {
    @StateObject private var viewModel = InspirationViewModel()
    @State private var showingCommentSheet: Bool = false
    @State private var selectedPostIndex: Int?

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(viewModel.posts.indices, id: \.self) { index in
                        PostView(post: $viewModel.posts[index])
                            .onTapGesture {
                                selectedPostIndex = index
                                showingCommentSheet = true
                            }
                    }
                }
                .padding()
            }
            .navigationTitle("Лента публикаций")
        }
        .sheet(isPresented: $showingCommentSheet) {
            if let index = selectedPostIndex {
                CommentsView(post: $viewModel.posts[index]) 
            }
        }
    }
}
