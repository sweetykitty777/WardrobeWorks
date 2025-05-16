//
//  PublicItemsSection.swift
//  diploma
//
//  Created by Olga on 08.05.2025.
//
import SwiftUI

struct PublicItemsSection: View {
    let items: [ClothItem]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Публичные вещи")
                .font(.headline)
                .padding(.leading)
                .padding(.top, 5)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(items, id: \ .id) { item in
                        NavigationLink {
                            ClothingDetailView(item: item)
                        } label: {
                            ClothItemProfileView(item: item)
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
