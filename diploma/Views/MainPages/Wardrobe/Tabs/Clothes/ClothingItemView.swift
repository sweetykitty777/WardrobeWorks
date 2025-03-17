//
//  ClothingItemView.swift
//  diploma
//
//  Created by Olga on 17.03.2025.
//

import Foundation
import SwiftUI

struct ClothingItemView: View {
    let item: ClothingItem
    @Binding var selectedItems: [OutfitItem]
    @State private var showDetailView = false

    var body: some View {
        VStack {
            if let imageName = item.image_str, let image = UIImage(named: imageName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onTapGesture {
                        showDetailView = true
                    }
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray) //
                    .onTapGesture {
                        showDetailView = true
                    }
            }

            Text(item.name)
                .font(.caption)
                .foregroundColor(.black)
        }
        .frame(width: 100)
        .onTapGesture {
            addItem(item)
        }
        .sheet(isPresented: $showDetailView) {
            ClothingDetailView(item: .constant(item), clothingItems: .constant([]))
        }
    }


    private func addItem(_ item: ClothingItem) {
        let newItem = OutfitItem(
            name: item.name,
            imageName: item.image_str ?? "placeholder",
            position: CGPoint(x: 150, y: 150)
        )
        selectedItems.append(newItem)
    }
}
