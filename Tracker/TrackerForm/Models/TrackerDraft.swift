import UIKit

struct TrackerDraft {
    var trackerName: String = ""
    var schedule: Set<WeekDay> = []
    var category: String?
    var emoji: String?
    var color: UIColor?

    var canCreate: Bool {
        !schedule.isEmpty && category != nil && isNameValid && emoji != nil
            && color != nil
    }

    var isNameValid: Bool {
        !trackerName.isEmpty
            && trackerName.count <= AppConstants.trackerNameValidationMaxLength
    }

    var scheduleSubtitle: String? {
        guard !schedule.isEmpty else { return nil }
        if schedule.count == WeekDay.allCases.count { return "Каждый день" }
        return WeekDay.allCases
            .filter { schedule.contains($0) }
            .map { $0.shortTitle }
            .joined(separator: ", ")
    }
}
