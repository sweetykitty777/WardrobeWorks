//
//  CommentsViewModel.swift
//  diploma
//
//  Created by Olga on 25.04.2025.
//

import Foundation
import Combine

class CommentsViewModel: ObservableObject {
    let postId: Int

    @Published var comments: [Comment] = []
    @Published var newCommentText: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    init(postId: Int) {
        self.postId = postId
        fetchComments()
    }

    func fetchComments() {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/social-service/comments/\(postId)") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        if let token = KeychainHelper.get(forKey: "accessToken") {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        isLoading = true
        URLSession.shared.dataTaskPublisher(for: req)
            .map(\.data)
            .decode(type: [Comment].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(err) = completion {
                    self?.errorMessage = "Не удалось загрузить комментарии: \(err.localizedDescription)"
                }
            } receiveValue: { [weak self] comments in
                self?.comments = comments
            }
            .store(in: &cancellables)
    }

    func addComment() {
        let text = newCommentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty,
              let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/social-service/comments/\(postId)/add")
        else { return }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = KeychainHelper.get(forKey: "accessToken") {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let body = ["text": text]
        req.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: req) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let err = error {
                    self?.errorMessage = "Ошибка отправки: \(err.localizedDescription)"
                    return
                }
                guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                    self?.errorMessage = "Сервер вернул ошибку"
                    return
                }
                self?.newCommentText = ""
                self?.fetchComments()
            }
        }.resume()
    }

    func deleteComment(_ commentId: Int) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/social-service/comments/\(commentId)") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        if let token = KeychainHelper.get(forKey: "accessToken") {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: req) { [weak self] _, response, error in
            DispatchQueue.main.async {
                if let err = error {
                    self?.errorMessage = "Ошибка удаления: \(err.localizedDescription)"
                    return
                }
                guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                    self?.errorMessage = "Не удалось удалить комментарий"
                    return
                }
                self?.fetchComments()
            }
        }.resume()
    }
}
