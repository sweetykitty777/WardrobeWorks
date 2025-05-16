// SocialServiceComments.swift
// diploma

import Foundation

extension SocialService {
    
    func fetchComments(for postId: Int, completion: @escaping (Result<[Comment], Error>) -> Void) {
        api.request(
            path: "/social-service/comments/\(postId)",
            method: "GET",
            decodeTo: [Comment].self,
            completion: completion
        )
    }

    func addComment(to postId: Int, text: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let body = try? JSONEncoder().encode(["text": text])
        api.requestVoid(
            path: "/social-service/comments/\(postId)/add",
            method: "POST",
            body: body,
            completion: completion
        )
    }

    func deleteComment(id commentId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        api.requestVoid(
            path: "/social-service/comments/\(commentId)",
            method: "DELETE",
            completion: completion
        )
    }
}
