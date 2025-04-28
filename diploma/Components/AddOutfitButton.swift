//
//  AddOutfitButton.swift
//  diploma
//
//  Created by Olga on 02.03.2025.
//

import Foundation
import SwiftUI

struct AddOutfitButton: View {
    @Binding var showingAddOutfitSheet: Bool

    var body: some View {
        Button(action: { showingAddOutfitSheet = true }) {
            HStack {
                Text("Добавить аутфит")
                    .fontWeight(.bold)
                Image(systemName: "plus.circle.fill")
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 50)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(25)
        }
        .padding(.horizontal, 20)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
