//
//  FullOutfitEditRequest.swift
//  diploma
//
//  Created by Olga on 07.05.2025.
//

import Foundation
import SwiftUI

struct FullOutfitEditRequest: Codable {
    let name: String
    let description: String
    let imagePath: String
    let clothes: [OutfitClothPlacement]
}
