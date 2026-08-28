import UIKit

protocol AddTrackerViewControllerDelegate: AnyObject {
    func addTrackerViewController(
        _ controller: AddTrackerViewController,
        didCreate tracker: Tracker,
        categoryTitle: String
    )
}

final class AddTrackerViewController: UIViewController {
    enum Option: String, CaseIterable {
        case category = "Категория"
        case schedule = "Расписание"
    }

    let contentView = AddHabitContentView()
    let scheduleVC = ScheduleViewController()
    var trackerDraft = TrackerDraft()
    weak var delegate: AddTrackerViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Новая привычка"
        setUpContentView()
        setUpTextField()
        setUpOptionTableView()
        setUpButtons()
        setUpKeyboardDismiss()
        setUpConstraints()
        renderDraftState()
    }

    // MARK: - Setup

    private func setUpContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
    }

    private func setUpTextField() {
        contentView.errorLabel.isHidden = true
        contentView.textField.returnKeyType = .done
        contentView.textField.delegate = self
        contentView.textField.addTarget(
            self,
            action: #selector(onTextChanged),
            for: .editingChanged
        )
    }

    private func setUpOptionTableView() {
        contentView.optionTableView.dataSource = self
        contentView.optionTableView.delegate = self
        scheduleVC.delegate = self
        contentView.optionTableView.heightAnchor.constraint(
            equalToConstant: AppConstants.optionRowHeight
                * CGFloat(Option.allCases.count)
        ).isActive = true
    }

    private func setUpButtons() {
        contentView.buttonsRow.cancelButton.addTarget(
            self,
            action: #selector(cancelButtonTapped),
            for: .touchUpInside
        )
        contentView.buttonsRow.createButton.addTarget(
            self,
            action: #selector(createButtonTapped),
            for: .touchUpInside
        )
    }

    private func setUpKeyboardDismiss() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            contentView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
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

    // MARK: - State

    func renderDraftState() {
        contentView.errorLabel.isHidden =
            trackerDraft.isNameValid || trackerDraft.trackerName.isEmpty
        contentView.buttonsRow.createButton.isEnabled = trackerDraft.canCreate
        contentView.buttonsRow.createButton.backgroundColor =
            trackerDraft.canCreate ? .black : .ypGray
    }

    func reloadOption(_ option: Option) {
        guard let row = Option.allCases.firstIndex(of: option) else { return }
        contentView.optionTableView.reloadRows(
            at: [IndexPath(row: row, section: 0)],
            with: .automatic
        )
        renderDraftState()
    }

    // MARK: - Actions

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func onTextChanged() {
        trackerDraft.trackerName = contentView.textField.text ?? ""
        renderDraftState()
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func createButtonTapped() {
        guard trackerDraft.canCreate,
            let categoryTitle = trackerDraft.category
        else { return }

        let tracker = Tracker(
            id: UUID(),
            name: trackerDraft.trackerName,
            color: .colorSelection5,
            emoji: "❤️",
            schedule: trackerDraft.schedule
        )
        delegate?.addTrackerViewController(
            self,
            didCreate: tracker,
            categoryTitle: categoryTitle
        )
        dismiss(animated: true)
    }
}
