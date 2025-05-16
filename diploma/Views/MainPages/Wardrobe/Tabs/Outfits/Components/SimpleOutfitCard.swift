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
            if let imagePath = outfit.imagePath {
                CachedImageView(
                    urlString: imagePath,
                    width: 140,
                    height: 200
                )
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    )
                    .frame(width: 140, height: 200)
            }
        }
    }
}
