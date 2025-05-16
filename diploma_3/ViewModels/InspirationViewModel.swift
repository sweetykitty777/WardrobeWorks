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

    func likePost(post: Post) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index].likes += 1
        }
    }

    func addComment(to post: Post, comment: String) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index].comments.append(comment)
        }
    }
}
