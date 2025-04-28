//
//  OutfitRenderer.swift
//  diploma
//
//  Created by Olga on 23.04.2025.
//

import Foundation
import SwiftUI

enum OutfitRenderer {
    static func render<V: View>(view: V, size: CGSize, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let controller = UIHostingController(rootView: view)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: size)

        DispatchQueue.main.async {
            let image = renderer.image { ctx in
                controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
            }
            completion(.success(image))
        }
    }
}
