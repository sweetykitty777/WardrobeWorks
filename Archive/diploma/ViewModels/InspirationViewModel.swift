//
//  InspirationViewModel.swift
//  diploma
//
//  Created by Olga on 11.03.2025.
//

import Foundation
import SwiftUI

class InspirationViewModel: ObservableObject {
    @Published var posts: [Post] = MockData.posts
    @Published var followedAuthors: Set<String> = []
    @Published var likedPosts: Set<UUID> = []

    // ✅ Лайк публикации
    func toggleLike(for post: Post) {
        if likedPosts.contains(post.id) {
            likedPosts.remove(post.id)
            updatePost(id: post.id) { $0.likes -= 1 }
        } else {
            likedPosts.insert(post.id)
            updatePost(id: post.id) { $0.likes += 1 }
        }
    }

    // ✅ Комментарии
    func addComment(to post: Post) {
        updatePost(id: post.id) { $0.comments.append("Новый комментарий") }
    }

    // ✅ Подписка на автора
    func toggleFollow(for post: Post) {
        if followedAuthors.contains(post.author) {
            followedAuthors.remove(post.author)
        } else {
            followedAuthors.insert(post.author)
        }
    }

    func isFollowing(_ post: Post) -> Bool {
        followedAuthors.contains(post.author)
    }

    func isLiked(_ post: Post) -> Bool {
        likedPosts.contains(post.id)
    }

    // ✅ Копирование аутфита
    func copyOutfit(_ outfit: Outfit) {
        // Здесь можно добавить логику сохранения в гардероб
    }

    private func updatePost(id: UUID, action: (inout Post) -> Void) {
        if let index = posts.firstIndex(where: { $0.id == id }) {
            action(&posts[index])
        }
    }
}
