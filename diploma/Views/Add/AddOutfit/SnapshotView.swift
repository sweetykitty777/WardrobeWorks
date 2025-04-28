//
//  SnapshotView.swift
//  diploma
//
//  Created by Olga on 23.04.2025.
//

import Foundation
import SwiftUI

struct SnapshotView<Content: View>: UIViewRepresentable {
    let content: Content
    let size: CGSize
    let completion: (UIImage) -> Void

    init(size: CGSize, @ViewBuilder content: () -> Content, completion: @escaping (UIImage) -> Void) {
        self.content = content()
        self.size = size
        self.completion = completion
    }

    func makeUIView(context: Context) -> UIView {
        let controller = UIHostingController(rootView: content)
        controller.view.frame = CGRect(origin: .zero, size: size)
        controller.view.backgroundColor = .clear

        DispatchQueue.main.async {
            let renderer = UIGraphicsImageRenderer(size: size)
            let image = renderer.image { ctx in
                controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
            }
            completion(image)
        }

        return controller.view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
