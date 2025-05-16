import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = UserProfileViewModel()

    @State private var isEditing = false
    @State private var showFollowers = false
    @State private var showFollowings = false
    @State private var selectedPostForEdit: Post?
    @State private var showEditPostSheet = false

    @State private var showingCommentSheet = false
    @State private var commentViewModel: CommentsViewModel?

    @StateObject private var followersVM = FollowListViewModel()
    @StateObject private var followingsVM = FollowListViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Buttons moved from toolbar
                    HStack(spacing: 16) {
                        Spacer()
                        Button(action: { isEditing = true }) {
                            Image(systemName: "pencil")
                                .font(.title2)
                        }
                        Button(action: { authViewModel.logout() }) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.top)

                    UserProfileHeader(user: viewModel.user)

                    FollowStatsSection(
                        followersVM: followersVM,
                        followingsVM: followingsVM,
                        showFollowers: $showFollowers,
                        showFollowings: $showFollowings
                    )

                    Divider()

                    UserPostsSection(
                        posts: viewModel.posts,
                        onEdit: { post in
                            selectedPostForEdit = post
                            showEditPostSheet = true
                        },
                        onComment: { post in
                            commentViewModel = CommentsViewModel(postId: post.id)
                            showingCommentSheet = true
                        }
                    )

                    PublicItemsSection(items: viewModel.publicItems)
                    PublicOutfitsSection(outfits: viewModel.publicOutfits)
                    PublicLookbooksSection(lookbooks: viewModel.publicLookbooks)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            // Toolbar removed
            .onAppear {
                viewModel.loadUserProfile()
                followersVM.fetchFollowers()
                followingsVM.fetchFollowings()
            }
            .sheet(isPresented: $isEditing) {
                NavigationStack {
                    EditProfileView(viewModel: viewModel)
                }
            }
            .sheet(isPresented: $showFollowers) {
                NavigationStack {
                    FollowListView(viewModel: followersVM, title: "Подписчики")
                }
            }
            .sheet(isPresented: $showFollowings) {
                NavigationStack {
                    FollowingListView(viewModel: followingsVM, title: "Подписки")
                }
            }
            .sheet(isPresented: $showingCommentSheet) {
                if let vm = commentViewModel {
                    NavigationStack {
                        CommentsView(viewModel: vm)
                            .navigationTitle("Комментарии")
                    }
                }
            }
            .sheet(item: $selectedPostForEdit) { post in
                NavigationStack {
                    EditPostView(post: post, profileViewModel: viewModel)
                }
            }
        }
    }
}
