import UIKit

extension AddTrackerViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        Option.allCases.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: OptionsTableView.cellIdentifier
            )
        else {
            fatalError("Failed to dequeue reusable cell")
        }

        let option = Option.allCases[indexPath.row]

        cell.backgroundColor = .backgroundDay
        cell.accessoryType = .disclosureIndicator

        var content = cell.defaultContentConfiguration()
        content.text = option.rawValue
        content.textProperties.font = .ypRegular17
        content.secondaryTextProperties.font = .ypRegular17
        content.secondaryTextProperties.color = .ypGray

        switch option {
        case .category: content.secondaryText = trackerDraft.category
        case .schedule: content.secondaryText = trackerDraft.scheduleSubtitle
        }

        cell.contentConfiguration = content

        if indexPath.row == Option.allCases.count - 1 {
            cell.separatorInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: 0,
                right: .greatestFiniteMagnitude
            )
        }

        return cell
    }
}
