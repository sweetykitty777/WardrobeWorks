import Foundation
import SwiftUI

struct ClothItemProfileView: View {
    let item: ClothItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            if !item.imagePath.isEmpty {
                CachedImageView(
                    urlString: item.imagePath,
                    width: nil,
                    height: 140
                )
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width:200, height: 140)

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
    }
}
