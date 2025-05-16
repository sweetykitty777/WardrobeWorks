//
//  NavigationRouter.swift
//  diploma
//
//  Created by Olga on 10.05.2025.
//

import SwiftUI

// ViewModifier для подключения всех navigationDestination
struct NavigationRouter: ViewModifier {
    func body(content: Content) -> some View {
        content
            // Пользователь: собственный календарь
            .navigationDestination(for: UserProfile.self) { user in
                UserCalendarView(userId: user.id)
            }

            // Аутфит (закрытый)
            .navigationDestination(for: OutfitResponse.self) { outfit in
                OutfitDetailView(outfit: outfit)
            }

            // Одежда
            .navigationDestination(for: ClothItem.self) { item in
                ClothingDetailView(item: item)
            }

            // Лукбук (с wardrobeId)
            .navigationDestination(for: LookbookResponse.self) { collection in
                LookbookDetailView(lookbook: collection, wardrobeId: collection.wardrobeId)
            }

            // Публичная одежда
            .navigationDestination(for: PublicClothRoute.self) { route in
                ClothingDetailViewPublic(item: route.item)
            }

            // Публичный аутфит
            .navigationDestination(for: PublicOutfitRoute.self) { route in
                OutfitDetailPublicView(outfit: route.outfit)
            }

            // Публичный лукбук
            .navigationDestination(for: PublicLookbookRoute.self) { route in
                LookbookDetailView(lookbook: route.lookbook, wardrobeId: nil)
            }

            // Профиль другого пользователя
            .navigationDestination(for: UserProfileRoute.self) { route in
                OtherUserProfileView(userId: route.userId)
            }
        
            .navigationDestination(for: OtherUserRoute.self) { route in
                OtherUserProfileView(userId: route.userId)
            }

    }
}
extension View {
    func applyNavigationRouter() -> some View {
        self.modifier(NavigationRouter())
    }
}
