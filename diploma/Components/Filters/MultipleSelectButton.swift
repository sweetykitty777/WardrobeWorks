//
//  MultipleSelectButton.swift
//  diploma
//
//  Created by Olga on 10.03.2025.
//

import Foundation
import SwiftUI

struct MultipleSelectButton: View {
    let title: String
    @Binding var selectedOptions: Set<String>

    var body: some View {
        Button(action: {
            if selectedOptions.contains(title) {
                selectedOptions.remove(title)
            } else {
                selectedOptions.insert(title) 
            }
        }) {
            Text(title)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(selectedOptions.contains(title) ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(selectedOptions.contains(title) ? .white : .black)
                .cornerRadius(20)
        }
    }
}
