//
//  PublicLookbooksSection.swift
//  diploma
//
//  Created by Olga on 08.05.2025.
//

import SwiftUI

struct PublicLookbooksSection: View {
    let lookbooks: [LookbookResponse]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Публичные лукбуки")
                .font(.headline)
                .padding(.leading)
                .padding(.top, 5)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(lookbooks, id: \.id) { lookbook in
                        NavigationLink {
                            LookbookDetailView(lookbook: lookbook, wardrobeId: nil)
                        } label: {
                            ProfileLookbookItemView(
                                title: lookbook.name,
                                subtitle: lookbook.description
                            )
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
