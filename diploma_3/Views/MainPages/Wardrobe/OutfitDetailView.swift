//
//  OutfitDetailView.swift
//  diploma
//
//  Created by Olga on 17.03.2025.
//

import Foundation
import SwiftUI

struct OutfitDetailView: View {
    let outfit: Outfit

    var body: some View {
        VStack {
            // ✅ Отображаем изображение аутфита
            if let imageName = outfit.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding()
            } else {
                Image(systemName: "photo") // ✅ Заглушка, если нет изображения
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .foregroundColor(.gray)
                    .padding()
            }

            Text(outfit.name)
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 10)

            Text("Состав аутфита:")
                .font(.headline)
                .padding(.horizontal)

            // ✅ Список вещей, входящих в аутфит
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(outfit.outfitItems, id: \.id) { item in
                        VStack {
                            Image(item.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            Text(item.name)
                                .font(.caption)
                                .foregroundColor(.black)
                        }
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .navigationTitle(outfit.name) // ✅ Заголовок страницы — название аутфита
        .navigationBarTitleDisplayMode(.inline)
    }
}
