import UIKit

extension ScheduleViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        WeekDay.allCases.count
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

        let day = WeekDay.allCases[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = day.fullTitle
        content.textProperties.font = .ypRegular17
        cell.contentConfiguration = content
        cell.backgroundColor = .backgroundDay

        let switcher = UISwitch()
        switcher.onTintColor = .ypBlue
        switcher.isOn = selectedWeekDays.contains(day)
        switcher.tag = indexPath.row
        switcher.addTarget(
            self,
            action: #selector(dayToggled(_:)),
            for: .valueChanged
        )
        cell.accessoryView = switcher

        if indexPath.row == WeekDay.allCases.count - 1 {
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
