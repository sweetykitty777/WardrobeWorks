import SwiftUI

struct OutfitCardView: View {
    let outfit: OutfitResponse

    var body: some View {
        VStack(spacing: 0) {
            if let url = outfit.imagePath {
                CachedImageView(
                    urlString: url,
                    width: nil,
                    height: 140
                )
            } else {
                placeholder
            }
        }
        .padding(8)
        .background(Color.white)
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
            Image(systemName: "photo")
                .font(.system(size: 36))
                .foregroundColor(.gray)
        }
        .frame(width: 110, height: 150)
    }
}
