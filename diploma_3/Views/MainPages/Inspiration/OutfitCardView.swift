import SwiftUI

struct OutfitCard: View {
    var outfit: Outfit

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageName = outfit.imageName, let image = UIImage(named: imageName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 140)

                    Image(systemName: "photo")
                        .font(.system(size: 36))
                        .foregroundColor(.gray)
                }
            }

            Text(outfit.name)
                .font(.system(size: 16, weight: .semibold))
                .lineLimit(1)

            Text("\(outfit.outfitItems.count) вещей")
                .font(.system(size: 13))
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
