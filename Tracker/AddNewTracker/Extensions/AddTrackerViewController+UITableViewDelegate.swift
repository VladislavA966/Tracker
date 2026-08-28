import UIKit

extension AddTrackerViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch Option.allCases[indexPath.row] {
        case .category: selectCategory()
        case .schedule: selectSchedule()
        }
    }

    private func selectCategory() {
        trackerDraft.category = "Важное"
        reloadOption(.category)
    }

    private func selectSchedule() {
        present(
            UINavigationController(rootViewController: scheduleVC),
            animated: true
        )
    }
}
