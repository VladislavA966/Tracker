import UIKit

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
