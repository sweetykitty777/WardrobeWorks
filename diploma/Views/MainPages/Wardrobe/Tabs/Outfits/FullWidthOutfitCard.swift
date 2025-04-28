import SwiftUI

struct FullWidthOutfitCard: View {
    let outfit: OutfitResponse
    private let maxDimension: CGFloat = 250

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imagePath = outfit.imagePath, !imagePath.isEmpty, let url = URL(string: imagePath) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: maxDimension,
                                   maxHeight: maxDimension)
                    case .empty:
                        ProgressView()
                            .frame(width: maxDimension, height: maxDimension)
                    case .failure:
                        placeholderView
                    @unknown default:
                        placeholderView
                    }
                }
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
                .frame(width: maxDimension, height: maxDimension)
            Image(systemName: "photo")
                .font(.system(size: 48))
                .foregroundColor(.gray)
        }
    }
}
