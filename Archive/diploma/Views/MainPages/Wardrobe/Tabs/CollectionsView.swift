//
//  CollectionsView.swift
//  diploma
//
//  Created by Olga on 03.03.2025.
//
import SwiftUI

struct CollectionsView: View {
    @StateObject private var collectionsViewModel = OutfitCollectionsViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(collectionsViewModel.collections) { collection in
                    NavigationLink(destination: OutfitCollectionDetailPlaceholder()) { // Заглушка вместо реального экрана
                        VStack(alignment: .leading) {
                            Text(collection.name)
                                .font(.headline)
                            Text("\(collection.outfits.count) аутфитов")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Коллекции аутфитов")
            .toolbar {
                Button(action: {
                    collectionsViewModel.addCollection(name: "Новая коллекция")
                }) {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

/// **Заглушка для экрана деталей**
struct OutfitCollectionDetailPlaceholder: View {
    var body: some View {
        Text("Экран деталей коллекции в разработке")
            .font(.headline)
            .foregroundColor(.gray)
            .padding()
            .navigationTitle("Детали коллекции")
    }
}
