//
//  NewCollectionView.swift
//  diploma
//
//  Created by Olga on 17.03.2025.
//

import Foundation
import SwiftUI

struct NewCollectionView: View {
    @Binding var collections: [Collection]
    @Binding var isPresented: Bool
    @State private var collectionName: String = ""

    var body: some View {
        NavigationView {
            VStack {
                TextField("Введите название лукбука", text: $collectionName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Создать") {
                    if !collectionName.isEmpty {
                        let newCollection = Collection(name: collectionName, outfits: [])
                        collections.append(newCollection)
                        isPresented = false
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
                .padding()

                Spacer()
            }
            .navigationTitle("Новый лукбук")
            .navigationBarItems(trailing: Button("Отмена") {
                isPresented = false 
            })
        }
    }
}
