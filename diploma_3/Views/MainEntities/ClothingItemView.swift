//
//  ClothingItemView.swift
//  diploma
//
//  Created by Olga on 15.03.2025.
//

import Foundation
import SwiftUI

struct ClothingItemView: View {
    let item: ClothingItem

    var body: some View {
        VStack {
            if let uiImage = item.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            } else if let imageName = item.image_str {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            } else {
                Image(systemName: "photo") // Заглушка, если изображения нет
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }

            Text(item.name)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .frame(width: 100)
    }
}
