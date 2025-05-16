//
//  CreatePostView.swift
//  diploma
//
//  Created by Olga on 17.03.2025.
//

import Foundation
import SwiftUI


struct CreatePostView: View {
    @Binding var posts: [Post]
    @State private var selectedOutfit: Outfit? = nil
    @State private var description: String = ""
    @State private var author: String = ""
    @State private var showingOutfitSelection = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {

                if let outfit = selectedOutfit {
                    VStack {
                        if let imageName = outfit.imageName, let image = UIImage(named: imageName) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 4)
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .foregroundColor(.gray)
                        }
                        
                        Text(outfit.name)
                            .font(.headline)
                            .padding(.top, 5)
                        
                        Button(action: {
                            showingOutfitSelection = true
                        }) {
                            Text("Выбрать другой аутфит")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 5)
                    }
                } else {

                    Button(action: {
                        showingOutfitSelection = true
                    }) {
                        HStack {
                            Text("Выбрать аутфит")
                                .foregroundColor(.blue)
                            Spacer()
                            Image(systemName: "chevron.down")
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 1)
                    }
                    .padding(.horizontal)
                }

                TextField("Описание поста", text: $description)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button(action: createPost) {
                    Text("Опубликовать пост")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(selectedOutfit == nil || author.isEmpty)

                Spacer()
            }
            .padding(.top)
            .navigationTitle("Создать пост")
            .sheet(isPresented: $showingOutfitSelection) {
                OutfitSelectionView(selectedOutfit: $selectedOutfit)
            }
        }
    }

    private func createPost() {
        guard let outfit = selectedOutfit, !author.isEmpty else { return }
        let newPost = Post(outfit: outfit, likes: 0, comments: [], description: description, author: author)
        posts.append(newPost)
    }
}
