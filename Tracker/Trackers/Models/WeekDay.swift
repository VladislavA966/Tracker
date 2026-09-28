import Foundation

enum WeekDay: CaseIterable {
    case monday,
        tuesday,
        wednesday,
        thursday,
        friday,
        saturday,
        sunday

    var fullTitle: String {
        Calendar.current.standaloneWeekdaySymbols[calendarWeekday - 1]
            .capitalized
    }

    var shortTitle: String {
        Calendar.current.shortStandaloneWeekdaySymbols[calendarWeekday - 1]
            .capitalized
    }

    var calendarWeekday: Int {
        switch self {
        case .sunday: 1
        case .monday: 2
        case .tuesday: 3
        case .wednesday: 4
        case .thursday: 5
        case .friday: 6
        case .saturday: 7
        }
    }

    init?(date: Date, calendar: Calendar = .current) {
        let weekday = calendar.component(.weekday, from: date)
        guard let day = WeekDay.allCases.first(where: { $0.calendarWeekday == weekday })
        else { return nil }
        self = day
    }
}
