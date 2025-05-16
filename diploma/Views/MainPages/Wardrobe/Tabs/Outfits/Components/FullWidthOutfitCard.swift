import SwiftUI

struct FullWidthOutfitCard: View {
    let outfit: OutfitResponse
    private let maxDimension: CGFloat = 250

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imagePath = outfit.imagePath, !imagePath.isEmpty {
                CachedImageView(
                    urlString: imagePath,
                    width: maxDimension,
                    height: maxDimension
                )
            } else {
                placeholderView
            }
        }
        .frame(width: maxDimension)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
    }

    private var placeholderView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
            Image(systemName: "photo")
                .font(.system(size: 48))
                .foregroundColor(.gray)
        }
        .frame(width: maxDimension, height: maxDimension)
    }
}
