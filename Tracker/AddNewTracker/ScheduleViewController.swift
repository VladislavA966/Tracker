import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelect(
        _ controller: ScheduleViewController,
        didSelect days: Set<WeekDay>
    )
}

final class ScheduleViewController: UIViewController {
    let tableView = OptionsTableView()
    let confirmButton = UIButton()
    var selectedWeekDays = Set<WeekDay>()
    weak var delegate: ScheduleViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Расписание"
        view.backgroundColor = .whiteDay
        setUpConfirmButton()
        setUpTableView()
        setUpConstraints()
    }

    // MARK: - Setup

    private func setUpConfirmButton() {
        view.addSubview(confirmButton)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.backgroundColor = .black
        confirmButton.titleLabel?.font = .ypMedium16
        confirmButton.setTitle("Готово", for: .normal)
        confirmButton.setTitleColor(.whiteDay, for: .normal)
        confirmButton.layer.cornerRadius = 16
        confirmButton.layer.masksToBounds = true
        confirmButton.addTarget(
            self,
            action: #selector(didTapDone),
            for: .touchUpInside
        )
    }

    private func setUpTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.allowsSelection = false
    }

    private func setUpConstraints() {
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
            tableView.heightAnchor.constraint(
                equalToConstant: AppConstants.optionRowHeight
                    * CGFloat(WeekDay.allCases.count)
            ),

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
                constant: -16
            ),
            confirmButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    // MARK: - Actions

    @objc private func didTapDone() {
        delegate?.didSelect(self, didSelect: selectedWeekDays)
        dismiss(animated: true)
    }

    @objc func dayToggled(_ sender: UISwitch) {
        let day = WeekDay.allCases[sender.tag]
        if sender.isOn {
            selectedWeekDays.insert(day)
        } else {
            selectedWeekDays.remove(day)
        }
    }
}
