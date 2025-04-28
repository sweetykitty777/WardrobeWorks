import Foundation
import SwiftUI

struct ClothItemProfileView: View {
    let item: ClothItem
    
    var body: some View {
        NavigationLink(destination: ClothingDetailView(item: item)) {
            VStack(alignment: .leading, spacing: 8) {
                // MARK: - Item Image
                if !item.imagePath.isEmpty {
                    RemoteImageView(urlString: item.imagePath)
                        .frame(height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4) 
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 140)

                        Image(systemName: "photo")
                            .font(.system(size: 36))
                            .foregroundColor(.gray)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
