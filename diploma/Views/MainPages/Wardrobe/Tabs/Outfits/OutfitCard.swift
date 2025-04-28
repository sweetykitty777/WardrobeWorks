//
//  OutfitCard.swift
//  diploma
//
//  Created by Olga on 23.04.2025.
//

import Foundation
import SwiftUI

struct OutfitCard: View {
    let outfit: OutfitResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let imagePath = outfit.imagePath,
               let url = URL(string: imagePath) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Color.gray.opacity(0.1)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Color.gray.opacity(0.1)
                    @unknown default:
                        Color.gray
                    }
                }
                .frame(height: 140)
                .clipped()
                .cornerRadius(8)
            } else {
                Color.gray
                    .frame(height: 140)
                    .cornerRadius(8)
            }

            Text(outfit.name)
                .font(.headline)
                .lineLimit(1)
                .foregroundColor(.primary)
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
