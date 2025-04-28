//
//  ImageRenderer.swift
//  diploma
//
//  Created by Olga on 23.04.2025.
//

import Foundation
import SwiftUI
import UIKit

@MainActor
class ImageRenderer {
    /// Преобразует SwiftUI View в UIImage
    static func renderImage<Content: View>(from view: Content, size: CGSize) -> UIImage? {
        let controller = UIHostingController(rootView: view)
        let view = controller.view

        let targetSize = CGSize(width: size.width, height: size.height)
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: view?.bounds ?? .zero, afterScreenUpdates: true)
        }
    }
}
