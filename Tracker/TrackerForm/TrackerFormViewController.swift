import UIKit

protocol TrackerFormViewControllerDelegate: AnyObject {
    func trackerFormViewController(
        _ controller: TrackerFormViewController,
        didCreate tracker: Tracker,
        categoryTitle: String
    )

    func trackerFormViewController(
        _ controller: TrackerFormViewController,
        didUpdate tracker: Tracker,
        categoryTitle: String
    )
}

final class TrackerFormViewController: UIViewController {
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

    let contentView = TrackerFormContentView()
    let scheduleVC = ScheduleViewController()
    var trackerDraft = TrackerDraft()
    weak var delegate: TrackerFormViewControllerDelegate?

    let mode: Mode

    init(mode: Mode = .create) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteDay
        setUpContentView()
        setUpTextField()
        setUpOptionTableView()
        setUpButtons()
        setUpKeyboardDismiss()
        setUpEmojisCollectionView()
        setUpColorsCollectionView()
        applyMode()
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
        contentView.errorLabel.font = .ypRegular17
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

    // MARK: - State

    func renderDraftState() {
        let hasError =
            !trackerDraft.isNameValid && !trackerDraft.trackerName.isEmpty
        contentView.errorLabel.isHidden = !hasError
        contentView.contentStack.setCustomSpacing(
            hasError ? 8 : 24,
            after: contentView.textField
        )
        contentView.buttonsRow.createButton.isEnabled = trackerDraft.canCreate
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
            id: mode.trackerId,
            name: trackerDraft.trackerName,
            color: color,
            emoji: emoji,
            schedule: trackerDraft.schedule
        )
        notifyDelegate(with: tracker, categoryTitle: categoryTitle)
        dismiss(animated: true)
    }
}
