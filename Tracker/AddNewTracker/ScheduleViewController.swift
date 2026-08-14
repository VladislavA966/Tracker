import UIKit

private let rowHeightConst = 75
protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelect(
        _ controller: ScheduleViewController,
        didSelect days: Set<WeekDay>
    )
}

enum WeekDay: CaseIterable {
    case monday,
        tuersday,
        wednesday,
        thursday,
        friday,
        saturday,
        sunday

    var fullTitle: String {
        switch self {
        case .monday: "Понедельник"
        case .tuersday: "Вторник"
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
        case .tuersday: "Вт"
        case .wednesday: "Ср"
        case .thursday: "Чт"
        case .friday: "Пт"
        case .saturday: "Сб"
        case .sunday: "Вс"
        }
    }
}

final class ScheduleViewController: UIViewController {
    let tableView = OptionsTableView()
    let confirmButton = UIButton()
    var selectedWeekDays = Set<WeekDay>()
    weak var delegate: ScheduleViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Расписание"
        view.addSubview(tableView)
        view.addSubview(confirmButton)
        
        ///Mark:  ConfirmButton config
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.backgroundColor = .black
        confirmButton.heightAnchor.constraint(equalToConstant: 60).isActive =
            true
        confirmButton.titleLabel?.textColor = .white
        confirmButton.layer.cornerRadius = 16
        confirmButton.layer.masksToBounds = true
        confirmButton.setTitle("Готово", for: .normal)
        confirmButton.addTarget(
            self,
            action: #selector(didTapDone),
            for: .touchUpInside
        )
        NSLayoutConstraint.activate([
            confirmButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            confirmButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            confirmButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: 16
            ),
        ])
        
        ///Mark: TableView config
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = false
        tableView.layer.masksToBounds = true
        tableView.allowsSelection = false
        tableView.rowHeight = CGFloat(rowHeightConst)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.heightAnchor.constraint(
            equalToConstant: CGFloat(rowHeightConst)
                * CGFloat(WeekDay.allCases.count)
        ).isActive = true

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
        ])
    }

    @objc func didTapDone() {
        delegate?.didSelect(self, didSelect: selectedWeekDays)
        dismiss(animated: true)
        print(selectedWeekDays)
    }
}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        WeekDay.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        else { return UITableViewCell() }
        let day = WeekDay.allCases[indexPath.row]
        cell.textLabel?.text = WeekDay.allCases[indexPath.row].fullTitle
        cell.backgroundColor = .backgroundDay
        let switcher = UISwitch()
        switcher.onTintColor = .ypBlue
        switcher.isOn = selectedWeekDays.contains(day)
        switcher.tag = indexPath.row
        cell.accessoryView = switcher
        switcher.addTarget(
            self,
            action: #selector(dayToggled(_:)),
            for: .valueChanged
        )

        return cell
    }

    @objc private func dayToggled(_ sender: UISwitch) {
        let day = WeekDay.allCases[sender.tag]
        if sender.isOn {
            selectedWeekDays.insert(day)
        } else {
            selectedWeekDays.remove(day)
        }
    }
}
