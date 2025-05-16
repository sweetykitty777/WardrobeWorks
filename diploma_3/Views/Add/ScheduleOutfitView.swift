//
//  ScheduleOutfitView.swift
//  diploma
//
//  Created by Olga on 23.03.2025.
//

import Foundation
import SwiftUI

struct ScheduleOutfitView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: CalendarOutfitViewModel
    let date: Date
    let outfits: [Outfit]

    @State private var selectedOutfit: Outfit?
    @State private var eventNote: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Выберите аутфит для \(date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.headline)

                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(outfits) { outfit in
                            OutfitCard(outfit: outfit)
                                .onTapGesture {
                                    selectedOutfit = outfit
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedOutfit?.id == outfit.id ? Color.blue : Color.clear, lineWidth: 2)
                                )
                        }
                    }
                }

                TextField("Введите событие (например, вечеринка)", text: $eventNote)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button("Сохранить") {
                    if let outfit = selectedOutfit {
                        viewModel.schedule(outfit: outfit, on: date, note: eventNote)
                        dismiss()
                    }
                }
                .disabled(selectedOutfit == nil)
                .padding()
                .background(selectedOutfit == nil ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Spacer()
            }
            .padding()
            .navigationTitle("Планировать аутфит")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
