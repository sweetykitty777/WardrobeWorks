import Foundation
import SwiftUI
import PostHog

class BackgroundEraserViewModel: ObservableObject {
    @Published var inputImage: UIImage
    @Published var erasePoints: [ErasePoint] = []

    @Published var brushSize: CGFloat = 40
    @Published var isAutoCropping = false
    @Published var progress: CGFloat = 0.0

    private let originalImage: UIImage
    private let removalService: BackgroundRemovalService

    private var hasLoggedManualErase = false

    init(image: UIImage, removalService: BackgroundRemovalService = BackgroundRemovalService()) {
        self.inputImage = image
        self.originalImage = image
        self.removalService = removalService
    }

    func addErasePoint(at location: CGPoint) {
        erasePoints.append(ErasePoint(point: location, size: brushSize))
        if !hasLoggedManualErase {
            PostHogSDK.shared.capture("background eraser used")
            hasLoggedManualErase = true
        }
    }

    func clearAll() {
        erasePoints.removeAll()
        PostHogSDK.shared.capture("eraser cleared")
    }

    func resetToOriginal() {
        inputImage = originalImage
        erasePoints.removeAll()
        PostHogSDK.shared.capture("eraser reset to original")
    }

    func undoLast() {
        guard !erasePoints.isEmpty else { return }
        erasePoints.removeLast()
        PostHogSDK.shared.capture("eraser undo last")
    }

    func startAutoCrop(completion: @escaping () -> Void) {
        guard let pngData = inputImage.pngData() else { return }

        isAutoCropping = true
        progress = 0.1

        PostHogSDK.shared.capture("background auto crop started")

        removalService.removeBackground(from: pngData) { [weak self] result in
            DispatchQueue.main.async {
                self?.isAutoCropping = false
                switch result {
                case .success(let newImg):
                    self?.inputImage = newImg
                    self?.erasePoints.removeAll()
                    PostHogSDK.shared.capture("background auto crop success")
                case .failure(let error):
                    PostHogSDK.shared.capture("background auto crop failed", properties: [
                        "error": error.localizedDescription
                    ])
                }
                completion()
            }
        }
    }

    func renderErasedImage(imageFrameInView: CGRect) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: inputImage.size)
        return renderer.image { ctx in
            inputImage.draw(in: CGRect(origin: .zero, size: inputImage.size))
            ctx.cgContext.setBlendMode(.clear)

            let scaleX = inputImage.size.width / imageFrameInView.width
            let scaleY = inputImage.size.height / imageFrameInView.height

            for p in erasePoints {
                let pt = CGPoint(
                    x: (p.point.x - imageFrameInView.origin.x) * scaleX,
                    y: (p.point.y - imageFrameInView.origin.y) * scaleY
                )
                let sz = p.size * ((scaleX + scaleY) / 2)
                let rect = CGRect(x: pt.x - sz / 2, y: pt.y - sz / 2, width: sz, height: sz)
                ctx.cgContext.fillEllipse(in: rect)
            }
        }
    }

    func aspectFitSize(for imageSize: CGSize, in containerSize: CGSize) -> CGSize {
        let aspectRatio = imageSize.width / imageSize.height
        let containerRatio = containerSize.width / containerSize.height
        if aspectRatio > containerRatio {
            let width = containerSize.width
            return CGSize(width: width, height: width / aspectRatio)
        } else {
            let height = containerSize.height
            return CGSize(width: height * aspectRatio, height: height)
        }
    }
}
