import SwiftUI

struct ClothItemView: View {
    let item: ClothItem
    @Binding var selectedItems: [OutfitItem]

    var body: some View {
        NavigationLink(destination: ClothingDetailView(item: item)) {
            VStack(alignment: .leading, spacing: 8) {
                if let url = URL(string: item.imagePath), !item.imagePath.isEmpty {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 110)
                                .cornerRadius(12)
                        case .empty, .failure:
                            placeholderView
                        @unknown default:
                            placeholderView
                        }
                    }
                } else {
                    placeholderView
                }
            }
            .padding(10)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var placeholderView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .frame(width: 150, height: 110)
            Image(systemName: "photo")
                .font(.system(size: 30))
                .foregroundColor(.gray)
        }
    }
}

struct ClothItemViewNotSelectable: View {
    let item: ClothItem

    var body: some View {
        NavigationLink(destination: ClothingDetailView(item: item)) {
            VStack(alignment: .leading, spacing: 8) {
                if let url = URL(string: item.imagePath), !item.imagePath.isEmpty {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 110)
                                .cornerRadius(12)
                        case .empty, .failure:
                            placeholderView
                        @unknown default:
                            placeholderView
                        }
                    }
                } else {
                    placeholderView
                }
            }
            .padding(10)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            .frame(width: 150)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var placeholderView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .frame(width: 150, height: 110)
            Image(systemName: "photo")
                .font(.system(size: 30))
                .foregroundColor(.gray)
        }
    }
}
