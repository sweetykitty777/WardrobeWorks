//
//  AllStatisticsResponse.swift
//  diploma
//
//  Created by Olga on 11.05.2025.
//
import Foundation

struct AllStatisticsResponse: Codable {
    let allOutfitsNumber: Int
    let allClothesNumber: Int
    let favouriteBrand: FavouriteBrand?
    let favouriteColour: FavouriteColour?
}
