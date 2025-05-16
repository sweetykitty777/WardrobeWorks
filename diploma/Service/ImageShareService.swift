//
//  ImageShareService.swift
//  diploma
//
//  Created by Olga on 03.05.2025.
//

import Foundation
import UIKit

struct ImageShareService {
    static func fetchImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            let image = data.flatMap { UIImage(data: $0) }
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}
