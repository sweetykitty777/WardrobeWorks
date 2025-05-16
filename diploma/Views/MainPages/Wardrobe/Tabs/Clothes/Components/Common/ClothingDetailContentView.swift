import SwiftUI

struct ClothingDetailContentView: View {
    let item: ClothItem

    var body: some View {
        VStack(spacing: 24) {
            // Фото
            if let url = URL(string: item.imagePath) {
                CachedImageView(
                    urlString: item.imagePath,
                    width: nil,
                    height: 280
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
            }

            VStack(alignment: .leading, spacing: 16) {
                InfoRow(title: "Бренд", value: item.brandName ?? "—")
                InfoRow(title: "Цвет", value: item.colourName ?? "—")
                InfoRow(title: "Сезон", value: item.seasonName ?? "—")
                InfoRow(title: "Категория", value: item.typeName ?? "—")
                InfoRow(title: "Цена", value: "\(item.price ?? 0) ₽")
                InfoRow(title: "Описание", value: item.description ?? "—")
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
    }
}
