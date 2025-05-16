//
//  FilterSection.swift
//  diploma
//
//  Created by Olga on 10.03.2025.
//

import Foundation
import SwiftUI

struct FilterSection: View {
    let title: String
    let options: [String]
    @Binding var selectedOptions: Set<String>

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(options, id: \.self) { option in
                        MultipleSelectButton(title: option, selectedOptions: $selectedOptions)
                    }
                }
                .padding(.horizontal, 5)
            }
        }
    }
}
