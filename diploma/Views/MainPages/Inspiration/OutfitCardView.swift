import SwiftUI

struct OutfitCard: View {
    var outfit: Outfit

    var body: some View {
        VStack {
    
            if let imageName = outfit.imageName, let image = UIImage(named: imageName){
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 4)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .foregroundColor(.gray)
            }

            Text(outfit.name)
                .font(.headline)
                .padding(.top, 8)

            Text("\(outfit.outfitItems.count) вещей")
                .font(.subheadline)
                .foregroundColor(.gray)

            Divider()
        }
        .background(Color.white)
        .cornerRadius(12)
        .padding(.bottom, 10)
    }
}
