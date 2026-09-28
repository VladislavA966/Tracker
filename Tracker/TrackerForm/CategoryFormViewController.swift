import UIKit

final class CategoryFormViewController: UIViewController {

    enum Mode {
        case create
        case edit(title: String)
    }

    var onDone: Bind<String>?

    private let mode: Mode

    private let textField = FormTextField()
    private let doneButton = PrimaryButton(title: String(localized: .commonDone))

    // MARK: - Init

    init(mode: Mode = .create) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteDay
        setUpTextField()
        applyMode()
        setUpDoneButton()
        updateDoneButtonState()
    }

    // MARK: - Setup

    private func setUpTextField() {
        textField.placeholder = String(localized: .categoryFormPlaceholder)
        textField.addTarget(
            self,
            action: #selector(onTextFieldChanged),
            for: .editingChanged
        )

        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 24
            ),
            textField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            textField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
        ])
    }

    private func setUpDoneButton() {
        doneButton.addTarget(
            self,
            action: #selector(onDoneButtonTapped),
            for: .touchUpInside
        )

        view.addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            doneButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            doneButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            doneButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
        ])
    }

    private func applyMode() {
        switch mode {
        case .create:
            navigationItem.title = String(localized: .categoryFormNewTitle)
        case .edit(let title):
            navigationItem.title = String(localized: .categoryFormEditTitle)
            textField.text = title
        }
    }

    // MARK: - State

    private var trimmedTitle: String {
        (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func updateDoneButtonState() {
        doneButton.isEnabled = !trimmedTitle.isEmpty
    }

    // MARK: - Actions

    @objc private func onTextFieldChanged() {
        updateDoneButtonState()
    }

    @objc private func onDoneButtonTapped() {
        onDone?(trimmedTitle)
    }
}
