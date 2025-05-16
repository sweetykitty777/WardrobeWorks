//
//  OutfitCache.swift
//  diploma
//
//  Created by Olga on 07.05.2025.
//

import Foundation

final class OutfitCache {
    static let shared = OutfitCache()
    private init() {}

    private let cache = NSCache<NSNumber, NSArray>()

    func get(for wardrobeId: Int) -> [OutfitResponse]? {
        cache.object(forKey: NSNumber(value: wardrobeId)) as? [OutfitResponse]
    }

    func set(_ outfits: [OutfitResponse], for wardrobeId: Int) {
        cache.setObject(outfits as NSArray, forKey: NSNumber(value: wardrobeId))
    }

    func clear() {
        cache.removeAllObjects()
    }
}
