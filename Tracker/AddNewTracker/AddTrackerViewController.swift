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

    let emojis = [
        "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🥭", "🍎", "🍏", "🍐", "🍒", "🍓", "🫐",
        "🥝", "🍅", "🫒",
    ]

    let colors: [UIColor] = [
        .colorSelection1, .colorSelection2, .colorSelection3,
        .colorSelection4, .colorSelection5, .colorSelection6,
        .colorSelection7, .colorSelection8, .colorSelection9,
        .colorSelection10, .colorSelection11, .colorSelection12,
        .colorSelection13, .colorSelection14, .colorSelection15,
        .colorSelection16, .colorSelection17, .colorSelection18,
    ]

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
        setUpEmojisCollectionView()
        setUpColorsCollectionView()
        renderDraftState()
    }

    // MARK: - Setup
    private func setUpEmojisCollectionView() {
        contentView.emojisCollectionView.dataSource = self
        contentView.emojisCollectionView.delegate = self
        contentView.emojisCollectionView.isScrollEnabled = false
        contentView.emojisCollectionView.register(
            EmojiCell.self,
            forCellWithReuseIdentifier: EmojiCell.reuseIdentifier
        )
    }

    private func setUpColorsCollectionView() {
        contentView.colorsCollectionView.dataSource = self
        contentView.colorsCollectionView.delegate = self
        contentView.colorsCollectionView.isScrollEnabled = false
        contentView.colorsCollectionView.register(
            ColorCell.self,
            forCellWithReuseIdentifier: ColorCell.reuseIdentifier
        )
    }

    private func setUpContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
        ])
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
        let hasError =
            !trackerDraft.isNameValid && !trackerDraft.trackerName.isEmpty
        contentView.errorLabel.isHidden = !hasError
        contentView.contentStack.setCustomSpacing(
            hasError ? 24 : 8,
            after: contentView.errorLabel
        )
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
            let categoryTitle = trackerDraft.category,
            let emoji = trackerDraft.emoji,
            let color = trackerDraft.color
        else { return }

        let tracker = Tracker(
            id: UUID(),
            name: trackerDraft.trackerName,
            color: color,
            emoji: emoji,
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
