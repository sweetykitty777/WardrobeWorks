//
//  WeekNavigationView.swift
//  diploma
//
//  Created by Olga on 02.03.2025.
//

import Foundation
import SwiftUI

struct WeekNavigationView: View {
    @ObservedObject var viewModel: WeeklyCalendarViewModel

    var body: some View {
        HStack {
            Button(action: { viewModel.changeWeek(by: -1) }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.gray)
                    .padding(.horizontal, 10)
            }

            Spacer()

            Text(viewModel.weekRange)
                .fontWeight(.regular)

            Spacer()

            Button(action: { viewModel.changeWeek(by: 1) }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .padding(.horizontal, 10)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}
