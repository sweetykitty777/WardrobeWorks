//
//  HeaderView.swift
//  diploma
//
//  Created by Olga on 02.03.2025.
//

import SwiftUI

struct HeaderView: View {
    @Binding var showingDatePicker: Bool
    @Binding var selectedDate: Date
    var onDateSelected: (Date) -> Void

    var body: some View {
        HStack {
            Spacer()
            Button(action: { showingDatePicker.toggle() }) {
                Image(systemName: "calendar")
                    .foregroundColor(.black)
                    .font(.system(size: 24))
                    .padding()
            }
            .sheet(isPresented: $showingDatePicker) {
                datePickerView
            }
        }
        .padding(.trailing, 20)
        .padding(.top, 0) 
    }

    private var datePickerView: some View {
        VStack {
            Text("Выберите дату")
                .font(.headline)
                .padding(.top)

            DatePicker("", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .labelsHidden()
                .padding()
                .onChange(of: selectedDate) { newDate in
                    onDateSelected(newDate)
                    showingDatePicker.toggle()
                }
        }
        .padding()
    }
}
