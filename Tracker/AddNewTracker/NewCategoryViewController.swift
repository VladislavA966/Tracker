import UIKit

final class NewCategoryViewController: UIViewController {

    var onDone: Bind<String>?

    private let textField = AddHabitTextField()
    private let doneButton = PrimaryButton(title: "Готово")

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Новая категория"
        view.backgroundColor = .whiteDay
        setUpTextField()
        setUpDoneButton()
        updateDoneButtonState()
    }

    // MARK: - Setup

    private func setUpTextField() {
        textField.placeholder = "Введите название категории"
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
