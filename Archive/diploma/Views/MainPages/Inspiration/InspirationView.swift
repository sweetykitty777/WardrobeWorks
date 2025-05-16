//
//  InspirationView.swift
//  diploma
//
//  Created by Olga on 11.03.2025.
//

import Foundation
import SwiftUI

struct InspirationView: View {
    @StateObject private var viewModel = InspirationViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.posts) { post in
                        PostView(post: post, viewModel: viewModel)
                            .padding(.bottom, 10)
                    }
                }
                .padding()
            }
            .navigationTitle("Вдохновение")
        }
    }
}
