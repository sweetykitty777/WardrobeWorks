//
//  NavigationRoutes.swift
//  diploma
//
//  Created by Olga on 10.05.2025.
//

import Foundation

// Используется в OtherUserProfileView → ClothingDetailViewPublic
struct PublicClothRoute: Hashable {
    let item: ClothItem
}

// Используется в OtherUserProfileView → OutfitDetailPublicView
struct PublicOutfitRoute: Hashable {
    let outfit: OutfitResponse
}

// Используется в OtherUserProfileView → LookbookDetailView
struct PublicLookbookRoute: Hashable {
    let lookbook: LookbookResponse
}

struct UserProfileRoute: Hashable {
    let userId: Int
}

struct OtherUserRoute: Hashable {
    let userId: Int
}


