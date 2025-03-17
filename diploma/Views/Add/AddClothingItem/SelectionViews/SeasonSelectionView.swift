//
//  SeasonSelectionView.swift
//  diploma
//
//  Created by Olga on 02.03.2025.
//

import Foundation
import SwiftUI

struct SeasonSelectionView: View {
    @Binding var selectedSeason: String

    let seasons = ["Лето", "Зима", "Осень", "Весна"]

    var body: some View {
        List {
            ForEach(seasons, id: \ .self) { season in
                Button(action: {
                    selectedSeason = season
                }) {
                    HStack {
                        Text(season)
                        Spacer()
                        if selectedSeason == season {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("Выберите сезон")
    }
}
