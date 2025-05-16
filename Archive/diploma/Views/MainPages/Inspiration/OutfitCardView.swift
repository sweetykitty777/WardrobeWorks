import SwiftUI

struct OutfitCard: View {
    var outfit: Outfit

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(outfit.name)
                .font(.headline)
            
            // ✅ Холст с вещами
            ZStack {
                Color.white
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .frame(height: 200)

                ForEach(outfit.outfitItems, id: \.id) { item in
                    Image(item.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .position(x: item.position.x, y: item.position.y)
                        .rotationEffect(.degrees(item.rotation))
                        .scaleEffect(item.scale)
                }
            }
            .padding(.vertical, 5)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

