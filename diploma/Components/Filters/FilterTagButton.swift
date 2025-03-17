//
//  FilterTagButton.swift
//  diploma
//
//  Created by Olga on 09.03.2025.
//

import Foundation
import SwiftUI

struct FilterTagButton: View {
    let title: String
    @Binding var selected: String?

    var body: some View {
        Button(action: {
            selected = (selected == title) ? nil : title
        }) {
            Text(title)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(selected == title ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(selected == title ? .white : .black)
                .cornerRadius(20)
        }
    }
}
