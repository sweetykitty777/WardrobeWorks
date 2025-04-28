//
//  FollowingListView.swift
//  diploma
//
//  Created by Olga on 25.04.2025.
//

import Foundation
import SwiftUI

struct FollowingListView: View {
    @ObservedObject var viewModel: FollowListViewModel
    var title: String

    var body: some View {
        List(viewModel.users) { user in
            NavigationLink(destination: OtherUserProfileView(userId: user.id)) {
                HStack(spacing: 12) {
                    if let avatarUrl = URL(string: user.avatar) {
                        AsyncImage(url: avatarUrl) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("@\(user.username)")
                            .font(.headline)
                        if !user.bio.isEmpty {
                            Text(user.bio)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.plain)
        .navigationTitle(title)
        .onAppear {
            viewModel.fetchFollowings() 
        }
    }
}
