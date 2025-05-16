//
//  UserProfileHeader.swift
//  diploma
//
//  Created by Olga on 08.05.2025.
//
import SwiftUI

struct UserProfileHeader: View {
    let user: UserProfile

    var body: some View {
        VStack(spacing: 8) {
            if let avatarURL = user.avatar {
                RemoteImageView(urlString: avatarURL, cornerRadius: 40, width: 80, height: 80)
            } else {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
            }

            Text("@\(user.username)")
                .font(.title2)
                .fontWeight(.semibold)

            if let bio = user.bio {
                Text(bio)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top)
    }
}
