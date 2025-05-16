import SwiftUI

struct DateInfo: Identifiable {
    let id: String
    let monthYear: String
    let dayOfWeek: String
    let dayOfMonth: String
}

struct ContentView: View {
    @State private var selectedDate: String? = nil
    @State private var dates: [DateInfo] = []

    let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    func generateDates() -> [DateInfo] {
        let calendar = Calendar.current
        var dates: [DateInfo] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        let startComponents = DateComponents(year: 2010, month: 1, day: 1)
        let endComponents = DateComponents(year: 2011, month: 12, day: 31)
        
        guard let startDate = calendar.date(from: startComponents),
              let endDate = calendar.date(from: endComponents) else {
            return []
        }
        
        var currentDate = startDate
        
        while currentDate <= endDate {
            let dayOfWeek = daysOfWeek[calendar.component(.weekday, from: currentDate) - 1]
            let dayOfMonth = calendar.component(.day, from: currentDate)
            let monthYear = dateFormatter.string(from: currentDate)
            let id = monthYear + dayOfWeek + String(dayOfMonth)
            
            let dateInfo = DateInfo(
                id: id,
                monthYear: monthYear,
                dayOfWeek: dayOfWeek,
                dayOfMonth: "\(dayOfMonth)"
            )
            
            dates.append(dateInfo)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }

    var body: some View {
        VStack {
            Text("Planner")
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(dates) { dateInfo in
                        VStack(spacing: 8) {
                            if dateInfo.dayOfMonth == "1" {
                                Text(dateInfo.monthYear)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                            }

                            Text(dateInfo.dayOfWeek)
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            Text(dateInfo.dayOfMonth)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .frame(width: 50, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(self.selectedDate == dateInfo.id ? Color.blue : Color.clear)
                                        .opacity(self.selectedDate == dateInfo.id ? 1 : 0.1)
                                )
                                .foregroundColor(self.selectedDate == dateInfo.id ? .white : .black)
                                .onTapGesture {
                                    self.selectedDate = self.selectedDate == dateInfo.id ? nil : dateInfo.id
                                }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
        .onAppear {
            self.dates = generateDates() 
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 13 mini")
    }
}
