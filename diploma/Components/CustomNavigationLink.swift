//
//  CustomNavigationLink.swift
//  diploma
//
//  Created by Olga on 02.03.2025.
//

import SwiftUI

struct CustomNavigationLink<Destination: View>: View {
    let title: String
    let value: String
    let destination: Destination

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)

            NavigationLink(destination: destination) {
                HStack {
                    Text(value.isEmpty ? "Добавить \(title.lowercased())" : value)
                        .foregroundColor(.black)
                        .font(.system(size: 16, weight: .medium))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(height: 44)
                .background(Color.white)
                .cornerRadius(14)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
        }
    }
}
