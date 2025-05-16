//
//  WardrobeServiceCache.swift
//  diploma
//
//  Created by Olga on 05.05.2025.
//

import Foundation

final class WardrobeCache {
    var cachedWardrobes: [UsersWardrobe]?
    var lastFetchTime: Date?

    var cachedClothes: [Int: [ClothItem]] = [:]
    var clothesFetchTime: [Int: Date] = [:]

    func isWardrobeCacheValid(ttl: TimeInterval) -> Bool {
        guard let lastFetchTime else { return false }
        return Date().timeIntervalSince(lastFetchTime) < ttl
    }

    func isClothesCacheValid(for wardrobeId: Int, ttl: TimeInterval) -> Bool {
        guard let fetchDate = clothesFetchTime[wardrobeId] else { return false }
        return Date().timeIntervalSince(fetchDate) < ttl
    }
}


/*
final class WardrobeServiceCache {
    static let shared = WardrobeServiceCache()
    
    private init() {}
    
    // Кэшированные гардеробы
    var wardrobes: [String: [UsersWardrobe]] = [:]
    
    // Кэш одежды
    var clothes: [Int: [ClothItem]] = [:]
    
    // Кэш аутфитов
    var outfits: [Int: [OutfitResponse]] = [:]
    
    // Кэш лукбуков
    var lookbooks: [Int: [LookbookResponse]] = [:]
}
*/
