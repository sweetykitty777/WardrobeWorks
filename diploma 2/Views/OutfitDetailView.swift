//
//  OutfitDetailView.swift
//  diploma
//
//  Created by Olga on 15.03.2025.
//

import Foundation
import SwiftUI

struct OutfitDetailView: View {
    var outfit: Outfit

    var body: some View {
        VStack {
            Text(outfit.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            ScrollView {
                VStack {
                    ForEach(outfit.outfitItems, id: \.id) { item in
                        HStack {
                            Image(item.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            Text(item.name)
                                .font(.headline)
                                .padding()
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(outfit.name)
    }
}
