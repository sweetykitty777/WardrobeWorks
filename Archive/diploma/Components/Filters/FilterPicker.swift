//
//  FilterPicker.swift
//  diploma
//
//  Created by Olga on 09.03.2025.
//

import Foundation
import SwiftUI

struct FilterPicker: View {
    let title: String
    @Binding var selection: String?
    let options: [String]

    var body: some View {
        Menu {
            Button("Не выбрано", action: { selection = nil }) // ✅ Возможность сбросить фильтр
            ForEach(options, id: \.self) { option in
                Button(option, action: { selection = option })
            }
        } label: {
            HStack {
                Text(selection ?? title)
                    .foregroundColor(selection == nil ? .gray : .black)
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
            }
            .padding(10)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 1)
        }
    }
}
