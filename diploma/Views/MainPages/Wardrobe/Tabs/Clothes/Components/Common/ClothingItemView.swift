import SwiftUI

struct ClothItemView: View {
    let item: ClothItem
    @Binding var selectedItems: [OutfitItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            CachedImageView(urlString: item.imagePath, width: 150, height: 110)
        }
        .padding(10)
        .cornerRadius(16)
    }
}

struct ClothItemViewNotSelectable: View {
    let item: ClothItem

    var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                CachedImageView(urlString: item.imagePath, width: 150, height: 110)
            }
            .padding(10)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            .frame(width: 150)
    }
}
