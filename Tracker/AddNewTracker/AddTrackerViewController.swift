import UIKit

private let rowHeightConst = 75

struct TrackerDraft {
    var trackerName: String = ""
    var schedule: Set<WeekDay> = []
    var category: String?

    var canCreate: Bool {
        !schedule.isEmpty && category != nil && isNameValid
    }

    var isNameValid: Bool {
        !trackerName.isEmpty
            && trackerName.count <= AppConstants.trackerNameValidationMaxLength
    }

    var scheduleSubtitle: String? {
        guard !schedule.isEmpty else { return nil }
        return WeekDay.allCases
            .filter { schedule.contains($0) }
            .map { $0.shortTitle }
            .joined(separator: ", ")
    }

}

extension AddTrackerViewController: ScheduleViewControllerDelegate {
    func didSelect(
        _ controller: ScheduleViewController,
        didSelect days: Set<WeekDay>
    ) {
        trackerDraft.schedule = days
        guard let rowIndex = setUpHabitOptions.firstIndex(of: "Расписание")
        else { return }
        contentView.optionTableView.reloadRows(
            at: [.init(row: rowIndex, section: 0)],
            with: .automatic
        )
        renderDraftState()
    }
}

final class AddTrackerViewController: UIViewController {
    let contentView = AddHabitContentView()
    private let setUpHabitOptions = ["Категория", "Расписание"]
    private let scheduleVC = ScheduleViewController()
    private var trackerDraft = TrackerDraft()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Новая привычка"
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.optionTableView.dataSource = self
        contentView.optionTableView.delegate = self
        scheduleVC.delegate = self
        contentView.errorLabel.isHidden = true
        contentView.textField.addTarget(
            self,
            action: #selector(onTextChanged),
            for: .editingChanged
        )
        contentView.optionTableView.heightAnchor.constraint(
            equalToConstant: CGFloat(rowHeightConst)
                * CGFloat(setUpHabitOptions.count)
        ).isActive = true
        view.addSubview(contentView)
        contentView.buttonsRow.cancelButton.addTarget(
            self,
            action: #selector(cancelButtonTapped),
            for: .touchUpInside
        )
        NSLayoutConstraint.activate([
            contentView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            contentView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            contentView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 24
            ),
            contentView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
        ])
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func createButtonTapped() {
        //        dismiss(animated: true)
    }

    @objc private func onTextChanged() {
        trackerDraft.trackerName = contentView.textField.text ?? ""
        renderDraftState()
    }

    private func renderDraftState() {
        contentView.errorLabel.isHidden =
            trackerDraft.isNameValid || trackerDraft.trackerName.isEmpty

        contentView.buttonsRow.createButton.isEnabled = trackerDraft.canCreate
        contentView.buttonsRow.createButton.backgroundColor =
            trackerDraft.canCreate ? .black : .ypGray
    }
}

extension AddTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        setUpHabitOptions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        else {
            fatalError("Failed to dequeue reusable cell")
        }

        cell.backgroundColor = .backgroundDay
        cell.accessoryType = .disclosureIndicator
        var content = cell.defaultContentConfiguration()
        content.text = setUpHabitOptions[indexPath.row]
        content.textProperties.font = .systemFont(ofSize: 17)
        content.secondaryTextProperties.font = .systemFont(ofSize: 17)
        content.secondaryTextProperties.color = .ypGray

        switch indexPath.row {
        case 0:
            content.secondaryText = trackerDraft.category
        case 1:
            content.secondaryText = scheduleSubtitle()
        default: break

        }

        cell.contentConfiguration = content

        if indexPath.row == setUpHabitOptions.count - 1 {
            cell.separatorInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: 0,
                right: .greatestFiniteMagnitude
            )
        }

        return cell
    }

    private func scheduleSubtitle() -> String? {
        guard !trackerDraft.schedule.isEmpty else { return nil }
        return trackerDraft.schedule.count == WeekDay.allCases.count
            ? "Каждый день"
            : WeekDay.allCases
                .filter { trackerDraft.schedule.contains($0) }
                .map { $0.shortTitle }
                .joined(separator: ", ")
    }
}

extension AddTrackerViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            selectCategory()
        case 1:
            selectDayOfWeek()
        default:
            break
        }
    }

    private func selectCategory() {
        trackerDraft.category = "Важное"
        guard let currentIndex = setUpHabitOptions.firstIndex(of: "Категория")
        else { return }
        contentView.optionTableView.reloadRows(
            at: [.init(row: currentIndex, section: 0)],
            with: .automatic
        )
        renderDraftState()
    }

    private func selectDayOfWeek() {
        let navigationController = UINavigationController(
            rootViewController: scheduleVC
        )
        present(navigationController, animated: true)
    }
}

final class AddHabitContentView: UIStackView {
    let textField = AddHabitTextField()
    let buttonsRow = ButtonsRow()
    let optionTableView = OptionsTableView()
    let errorLabel = ErrorLabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .vertical
        spacing = 24
        setCustomSpacing(8, after: textField)
        addArrangedSubview(textField)
        addArrangedSubview(errorLabel)
        addArrangedSubview(optionTableView)
        addArrangedSubview(UIView())
        addArrangedSubview(buttonsRow)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class ErrorLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        text =
            "Ограничение \(AppConstants.trackerNameValidationMaxLength) символов"
        textColor = .red
        textAlignment = .center
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")

    }
}

final class AddHabitTextField: UITextField {
    var contentInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        super.textRect(forBounds: bounds).inset(by: contentInsets)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        super.editingRect(forBounds: bounds).inset(by: contentInsets)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        clearButtonMode = .whileEditing
        placeholder = "Введите название трекера"
        backgroundColor = .backgroundDay
        heightAnchor.constraint(equalToConstant: 75).isActive = true
        layer.cornerRadius = 16
        layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class ButtonsRow: UIStackView {
    let cancelButton = UIButton()
    let createButton = UIButton()

    init() {
        super.init(frame: .zero)
        axis = .horizontal
        distribution = .fillEqually
        spacing = 16
        createButton.setTitle("Создать", for: .normal)
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        setUpCancelButton()
        setUpCreateButton()
        addArrangedSubview(cancelButton)
        addArrangedSubview(createButton)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpCancelButton() {
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(.ypRed, for: .normal)
        cancelButton.backgroundColor = .clear
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderColor = UIColor.ypRed.cgColor
        cancelButton.layer.borderWidth = 1

    }

    private func setUpCreateButton() {
        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.whiteDay, for: .normal)
        createButton.backgroundColor = .ypGray
        createButton.layer.cornerRadius = 16
    }

}

final class OptionsTableView: UITableView {
    override init(frame: CGRect = .zero, style: UITableView.Style = .plain) {
        super.init(frame: frame, style: style)
        layer.cornerRadius = 16
        isScrollEnabled = false
        layer.masksToBounds = true
        rowHeight = CGFloat(rowHeightConst)
        tableHeaderView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 0,
                height: CGFloat.leastNormalMagnitude
            )
        )
        tableFooterView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 0,
                height: CGFloat.leastNormalMagnitude
            )
        )
        register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
