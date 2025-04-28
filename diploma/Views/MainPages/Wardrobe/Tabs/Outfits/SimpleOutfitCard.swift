//
//  SimpleOutfitCard.swift
//  diploma
//
//  Created by Olga on 28.04.2025.
//

import Foundation
import SwiftUI

struct SimpleOutfitCard: View {
    let outfit: OutfitResponse

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            if let imagePath = outfit.imagePath, let url = URL(string: imagePath) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                    default:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                            )
                    }
                }
                .frame(height: 140)
            }
        }
    }
}
