import Foundation

enum TrackerFilter: CaseIterable {
    case all
    case today
    case completed
    case uncompleted

    var title: String {
        switch self {
        case .all: "Все трекеры"
        case .today: "Трекеры на сегодня"
        case .completed: "Завершённые"
        case .uncompleted: "Незавершённые"
        }
    }

    /// «Все» и «На сегодня» — это сброс, а не фильтр: галочку не ставим, кнопку не красим.
    var isActive: Bool {
        switch self {
        case .all, .today: false
        case .completed, .uncompleted: true
        }
    }
}
