import SwiftUI

struct ClothingDetailView: View {
    @Binding var item: ClothingItem
    @Binding var clothingItems: [ClothingItem]
    @Environment(\.presentationMode) var presentationMode
    

    var body: some View {
        VStack {
            if let imageName = item.image_str, let image = UIImage(named: imageName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray) 
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.top, 50)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray) 
            }
        }.frame(width: 100)
        VStack {
            Form {
                Section(header: Text("Основная информация")) {
                    Text("Название: \(item.name)")
                    if let brand = item.brand {
                        Text("Бренд: \(brand)")
                    }
                    if let color = item.color {
                        Text("Цвет: \(color)")
                    }
                    if let season = item.season {
                        Text("Сезон: \(season)")
                    }
                    if let price = item.price {
                        Text("Цена: \(price)")
                    }
                }
            }
        }
        .navigationTitle("Детали вещи")
        .navigationBarTitleDisplayMode(.inline)
    }
}
