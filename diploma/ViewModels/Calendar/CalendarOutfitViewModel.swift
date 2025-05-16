import Foundation
import PostHog

class CalendarOutfitViewModel: ObservableObject {
    @Published var scheduledOutfits: [ScheduledOutfit] = []

    func schedule(outfit: Outfit, on date: Date, note: String) {
        let newEntry = ScheduledOutfit(date: date, outfit: outfit, eventNote: note)
        scheduledOutfits.append(newEntry)

        PostHogSDK.shared.capture("calendar_outfit_scheduled", properties: [
            "outfit_id": outfit.id,
            "scheduled_date": date.formatted(.iso8601),
            "note_length": note.count
        ])
    }

    func outfits(for date: Date) -> [ScheduledOutfit] {
        let outfitsForDate = scheduledOutfits.filter {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }

        PostHogSDK.shared.capture("calendar_outfits_requested", properties: [
            "date": date.formatted(.iso8601),
            "found": outfitsForDate.count
        ])

        return outfitsForDate
    }
}
