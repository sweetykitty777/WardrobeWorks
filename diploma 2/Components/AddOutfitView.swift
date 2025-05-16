//
//  AddOutfitView.swift
//  diploma
//
//  Created by Olga on 09.03.2025.
//

import Foundation
import SwiftUI

struct AddOutfitButton: View {
    @Binding var showingAddOutfitSheet: Bool

    var body: some View {
        Button(action: {
            showingAddOutfitSheet = true
        }) {
            HStack {
                Text("Добавить аутфит")
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                Image(systemName: "plus.circle.fill")
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 1)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}
