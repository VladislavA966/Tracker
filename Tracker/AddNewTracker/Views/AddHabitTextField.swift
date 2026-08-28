import UIKit

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
        font = .ypRegular17
        clearButtonMode = .whileEditing
        placeholder = "Введите название трекера"
        backgroundColor = .backgroundDay
        heightAnchor.constraint(
            equalToConstant: AppConstants.optionRowHeight
        ).isActive = true
        layer.cornerRadius = 16
        layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
