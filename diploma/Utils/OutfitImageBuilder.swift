import Foundation
import UIKit


struct OutfitImageBuilder {

    static func renderImage(
        from items: [PlacedClothingItem],
        images: [Int: UIImage],
        canvasSize: CGSize,
        completion: @escaping (UIImage?) -> Void
    ) {

        let padding: CGFloat = 20
        var minX = CGFloat.greatestFiniteMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        var maxX: CGFloat = 0
        var maxY: CGFloat = 0
        
        for item in items {
            let size = CGSize(width: 100 * item.scale, height: 100 * item.scale)
            let x = item.x - size.width / 2
            let y = item.y - size.height / 2
            minX = min(minX, x)
            minY = min(minY, y)
            maxX = max(maxX, x + size.width)
            maxY = max(maxY, y + size.height)
        }

        let fittedWidth = maxX - minX + padding * 2
        let fittedHeight = maxY - minY + padding * 2
        let fittedCanvasSize = CGSize(width: fittedWidth, height: fittedHeight)



        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: fittedCanvasSize, format: format)

        let finalImage = renderer.image { context in
            for item in items.sorted(by: { $0.zIndex < $1.zIndex }) {
                guard let image = images[item.clothId] else {
                    continue
                }

                let size = CGSize(width: 100 * item.scale, height: 100 * item.scale)
                let origin = CGPoint(
                    x: item.x - size.width / 2 - minX + padding,
                    y: item.y - size.height / 2 - minY + padding
                )

                context.cgContext.saveGState()
                context.cgContext.translateBy(x: origin.x + size.width / 2, y: origin.y + size.height / 2)
                context.cgContext.rotate(by: CGFloat(item.rotation * Double.pi / 180))
                context.cgContext.translateBy(x: -origin.x - size.width / 2, y: -origin.y - size.height / 2)

                image.draw(in: CGRect(origin: origin, size: size))
                context.cgContext.restoreGState()
            }
        }

        completion(finalImage)
    }

}
