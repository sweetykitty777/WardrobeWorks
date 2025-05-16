//
//  PublicOutfitsSection.swift
//  diploma
//
//  Created by Olga on 08.05.2025.
//

import SwiftUI

struct PublicOutfitsSection: View {
    let outfits: [OutfitResponse]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Публичные аутфиты")
                .font(.headline)
                .padding(.leading)
                .padding(.top, 5)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(outfits, id: \ .id) { outfit in
                        NavigationLink {
                            OutfitDetailView(outfit: outfit)
                        } label: {
                            OutfitCardView(outfit: outfit)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.leading)
                .padding(.top, 12)
            }
        }
        .padding(.top)
    }
}
