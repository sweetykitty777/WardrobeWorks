//
//  ToastView.swift
//  diploma
//
//  Created by Olga on 22.04.2025.
//

import Foundation
import SwiftUI

struct ToastView: View {
    let message: String
    var isError: Bool = false

    var body: some View {
        Text(message)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isError ? Color.red.opacity(0.85) : Color.black.opacity(0.85))
            .cornerRadius(12)
            .shadow(radius: 6)
    }
}
