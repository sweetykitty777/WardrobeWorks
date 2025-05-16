//
//  PlusTabButton.swift
//  diploma
//
//  Created by Olga on 03.03.2025.
//

import SwiftUI

struct PlusTabButton: View {
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 55, height: 55)
                .foregroundColor(.blue)

            Image(systemName: "plus")
                .resizable()
                .foregroundColor(.white)
                .frame(width: 25, height: 25)
        }
        .shadow(radius: 4)
        .offset(y: -10) 
    }
}
