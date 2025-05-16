//
//  SocialServicePost.swift
//  diploma
//
//  Created by Olga on 04.05.2025.
//

import Foundation

extension SocialService {

    func fetchUserPosts(userId: Int, completion: @escaping (Result<[Post], Error>) -> Void) {
        api.request(
            path: "/social-service/posts/byUser=\(userId)/",
            method: "GET",
            decodeTo: [Post].self,
            completion: completion
        )
    }

    func fetchPostFeed(completion: @escaping (Result<[Post], Error>) -> Void) {
        api.request(
            path: "/social-service/posts/feed",
            method: "GET",
            decodeTo: [Post].self,
            completion: completion
        )
    }

    func fetchPostById(_ id: Int, completion: @escaping (Result<Post, Error>) -> Void) {
        api.request(
            path: "/social-service/posts/\(id)",
            method: "GET",
            decodeTo: Post.self,
            completion: completion
        )
    }

    func createPost(payload: CreatePostRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let body = try? JSONEncoder().encode(payload) else {
            return completion(.failure(NSError(domain: "Encoding failed", code: 400)))
        }

        api.requestVoid(
            path: "/social-service/posts/create",
            method: "POST",
            body: body,
            completion: completion
        )
    }

    func deletePost(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        api.requestVoid(
            path: "/social-service/posts/\(id)",
            method: "DELETE",
            completion: completion
        )
    }

    func likePost(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        api.requestVoid(
            path: "/social-service/posts/\(id)/like",
            method: "POST",
            completion: completion
        )
    }

    func unlikePost(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        api.requestVoid(
            path: "/social-service/posts/\(id)/unlike",
            method: "DELETE",
            completion: completion
        )
    }
    
    func updatePostText(id: Int, newText: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let payload = ["text": newText]
        guard let body = try? JSONSerialization.data(withJSONObject: payload) else {
            return completion(.failure(NSError(domain: "Encoding failed", code: 400)))
        }

        api.requestVoid(
            path: "/social-service/posts/\(id)/update/text",
            method: "PATCH",
            body: body,
            completion: completion
        )
    }
    
    func createPost(outfit: OutfitResponse, text: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let payload = CreatePostRequest(
            text: text,
            postImages: [
                PostImagePayload(
                    imagePath: outfit.imagePath ?? "",
                    position: 0,
                    outfitId: outfit.id
                )
            ]
        )
        createPost(payload: payload, completion: completion)
    }

}
