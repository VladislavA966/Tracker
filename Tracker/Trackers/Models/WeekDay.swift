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
        switch self {
        case .monday: "Понедельник"
        case .tuesday: "Вторник"
        case .wednesday: "Среда"
        case .thursday: "Четверг"
        case .friday: "Пятница"
        case .saturday: "Суббота"
        case .sunday: "Воскресенье"
        }
    }

    var shortTitle: String {
        switch self {
        case .monday: "Пн"
        case .tuesday: "Вт"
        case .wednesday: "Ср"
        case .thursday: "Чт"
        case .friday: "Пт"
        case .saturday: "Сб"
        case .sunday: "Вс"
        }
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
