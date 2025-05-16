//
//  DayScrollView.swift
//  diploma
//
//  Created by Olga on 02.03.2025.
//

import Foundation
import SwiftUI

struct DaysScrollView: View {
    @ObservedObject var viewModel: WeeklyCalendarViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(viewModel.currentWeek, id: \.date) { day in
                    dayView(for: day)
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 100)
    }

    /// Отображение отдельного дня
    private func dayView(for day: CalendarDay) -> some View {
        VStack(spacing: 6) {
            Text(day.date.formattedDayOfWeek)
                .font(.subheadline)
                .foregroundColor(.gray)

            Text("\(Calendar.current.component(.day, from: day.date))")
                .fontWeight(.semibold)
                .padding(12)
                .background(day.isSelected ? Color.blue : Color.clear)
                .clipShape(Circle())
                .foregroundColor(day.isSelected ? .white : .black)
                .onTapGesture {
                    withAnimation {
                        viewModel.selectDate(day.date)
                    }
                }
        }
        .frame(width: 50)
    }
}

