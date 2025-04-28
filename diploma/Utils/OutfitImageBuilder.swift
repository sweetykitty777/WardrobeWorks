import Foundation
import UIKit

/// Собирает финальное изображение аутфита с прозрачным фоном и сохраняет его как PNG
struct OutfitImageBuilder {
    /// Рендерит изображение из наложенных вещей
    static func renderImage(
        from items: [PlacedClothingItem],
        images: [Int: UIImage],
        canvasSize: CGSize,
        completion: @escaping (UIImage?) -> Void
    ) {
        print("📐 Начинаем рендер → items: \(items.count)")

        // Расчет границ наложения
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

        // Размер конечного холста с отступами
        let fittedWidth = maxX - minX + padding * 2
        let fittedHeight = maxY - minY + padding * 2
        let fittedCanvasSize = CGSize(width: fittedWidth, height: fittedHeight)

        print("🎯 Новая область рендера: \(fittedCanvasSize), смещение: (\(minX), \(minY))")

        // Формат рендерера с поддержкой альфа-канала
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        format.opaque = false  // важно: разрешить прозрачность

        let renderer = UIGraphicsImageRenderer(size: fittedCanvasSize, format: format)

        let finalImage = renderer.image { context in
            // Ничего не заливаем — фон будет прозрачным
            
            // Рисуем каждый элемент в порядке zIndex
            for item in items.sorted(by: { $0.zIndex < $1.zIndex }) {
                guard let image = images[item.clothId] else {
                    print("❌ Нет изображения для clothId \(item.clothId)")
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
