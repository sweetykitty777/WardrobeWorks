//
//  RemoteImageView.swift
//  diploma
//
//  Created by Olga on 22.04.2025.
//

import Foundation
import SwiftUI

struct RemoteImageView: View {
    let urlString: String
    var cornerRadius: CGFloat = 10
    var width: CGFloat = 120
    var height: CGFloat = 120

    var body: some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            switch phase {
            case .empty:
                ZStack {
                    Color.gray.opacity(0.1)
                    ProgressView()
                }

            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()

            case .failure:
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .padding(20)
                    .foregroundColor(.gray)

            @unknown default:
                EmptyView()
            }
        }
        .frame(width: width, height: height)
        .background(Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .clipped()
    }
}
