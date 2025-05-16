//
//  UserPostsSection.swift
//  diploma
//
//  Created by Olga on 08.05.2025.
//
import SwiftUI

struct UserPostsSection: View {
    let posts: [Post]
    let onEdit: (Post) -> Void
    let onComment: (Post) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text("Публикации")
                .font(.headline)
                .padding(.leading)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(posts.sorted { $0.createdAt > $1.createdAt }, id: \ .id) { post in
                        let vm = PostViewModel(post: post)
                        PostView(viewModel: vm) {
                            onComment(post)
                        }
                        .contextMenu {
                            Button {
                                onEdit(post)
                            } label: {
                                Label("Редактировать", systemImage: "pencil")
                            }

                            Button(role: .destructive) {
                                SocialService.shared.deletePost(id: post.id) { _ in }
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(.leading)
                .padding(.top, 12)
            }
        }
    }
}
