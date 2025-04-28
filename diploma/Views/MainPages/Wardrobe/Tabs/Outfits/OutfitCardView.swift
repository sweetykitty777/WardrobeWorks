import SwiftUI

struct OutfitCard: View {
    let outfit: OutfitResponse

    var body: some View {
        NavigationLink(destination: OutfitDetailView(outfit: outfit)) {
            VStack(spacing: 0) {
                if let urlString = outfit.imagePath,
                   let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()          // сохраняем пропорции
                                .frame(maxWidth: .infinity)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        case .failure, .empty:
                            placeholder
                        @unknown default:
                            placeholder
                        }
                    }
                    .frame(height: 140)
                } else {
                    placeholder
                }
            }
            .padding(8)
            .background(Color.white)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .frame(height: 140)
            Image(systemName: "photo")
                .font(.system(size: 36))
                .foregroundColor(.gray)
        }
    }
}
