import UIKit

extension AddTrackerViewController: ScheduleViewControllerDelegate {
    func didSelect(
        _ controller: ScheduleViewController,
        didSelect days: Set<WeekDay>
    ) {
        trackerDraft.schedule = days
        reloadOption(.schedule)
    }
}
