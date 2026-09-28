import Foundation

enum TrackerFilter: CaseIterable {
    case all
    case today
    case completed
    case uncompleted

    var title: String {
        switch self {
        case .all: String(localized: .filtersAll)
        case .today: String(localized: .filtersToday)
        case .completed: String(localized: .filtersCompleted)
        case .uncompleted: String(localized: .filtersUncompleted)
        }
    }

    var isActive: Bool {
        switch self {
        case .all, .today: false
        case .completed, .uncompleted: true
        }
    }
}
