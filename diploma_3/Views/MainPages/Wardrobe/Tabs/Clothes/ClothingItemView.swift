import SwiftUI

struct ClothingItemView: View {
    let item: ClothingItem
    @Binding var selectedItems: [OutfitItem]
    @State private var clothingItems: [ClothingItem] = MockData.clothingItems

    var body: some View {
        if let index = clothingItems.firstIndex(where: { $0.id == item.id }) {
            NavigationLink(destination: ClothingDetailView(item: $clothingItems[index], clothingItems: $clothingItems)) {
                VStack(alignment: .leading, spacing: 8) {
                    if let imageName = item.image_str, let image = UIImage(named: imageName) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 110)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 110)

                            Image(systemName: "photo")
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
                        }
                    }

                }
                .padding(10)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                .frame(width: 150)
            }
        } else {
            VStack {
                Image(systemName: "xmark.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .foregroundColor(.red)
                Text("Не найдено")
                    .font(.caption)
                    .foregroundColor(.black)
            }
            .frame(width: 150)
        }
    }
}
