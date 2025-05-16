//
//  FollowStatsSection.swift
//  diploma
//
//  Created by Olga on 08.05.2025.
//
import SwiftUI

struct FollowStatsSection: View {
    @ObservedObject var followersVM: FollowListViewModel
    @ObservedObject var followingsVM: FollowListViewModel
    @Binding var showFollowers: Bool
    @Binding var showFollowings: Bool

    var body: some View {
        HStack(spacing: 40) {
            VStack {
                Text("\(followersVM.users.count)")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("Подписчики").font(.caption)
            }.onTapGesture {
                followersVM.fetchFollowers()
                showFollowers = true
            }

            VStack {
                Text("\(followingsVM.users.count)")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("Подписки").font(.caption)
            }.onTapGesture {
                followingsVM.fetchFollowings()
                showFollowings = true
            }
        }
    }
}
