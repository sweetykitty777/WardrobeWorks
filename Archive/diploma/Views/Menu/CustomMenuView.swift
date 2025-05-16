//
//  CustomMenuView.swift
//  diploma
//
//  Created by Olga on 01.02.2025.
//

import Foundation

import SwiftUI

struct CustomMenuView: View {
    var onAddClothes: () -> Void
    var onCreateOutfit: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            
            Button(action: onAddClothes) {
                HStack {
                    Text("Добавить вещь")
                        .font(.headline)
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 1)
            }
            .padding(.horizontal, 20)
            
            Button(action: onCreateOutfit) {
                HStack {
                    Text("Создать аутфит")
                        .font(.headline)
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 1)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    }
}
