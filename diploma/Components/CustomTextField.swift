//
//  CustomTextField.swift
//  diploma
//
//  Created by Olga on 02.03.2025.
//

import Foundation
import SwiftUI

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var characterLimit: Int? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)

            TextField("Введите \(title.lowercased())...", text: Binding(
                get: { self.text },
                set: {
                    if let limit = characterLimit, $0.count > limit {
                        self.text = String($0.prefix(limit))
                    } else {
                        self.text = $0
                    }
                })
            )
            .keyboardType(keyboardType)
            .padding()
            .background(Color.white)
            .cornerRadius(14)
            .font(.system(size: 16, weight: .medium))
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
}
