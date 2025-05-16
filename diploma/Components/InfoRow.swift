//
//  InfoRow.swift
//  diploma
//
//  Created by Olga on 04.05.2025.
//

import Foundation
import SwiftUI

struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title).fontWeight(.semibold)
            Spacer()
            Text(value).foregroundColor(.gray)
        }
        .font(.system(size: 16))
    }
}
