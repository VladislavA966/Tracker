import UIKit

final class ButtonsRow: UIStackView {
    let cancelButton = UIButton()
    let createButton = UIButton()

    init() {
        super.init(frame: .zero)
        axis = .horizontal
        distribution = .fillEqually
        spacing = 16
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
        cancelButton.titleLabel?.font = .ypMedium16
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(.ypRed, for: .normal)
        cancelButton.backgroundColor = .clear
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderColor = UIColor.ypRed.cgColor
        cancelButton.layer.borderWidth = 1
    }

    private func setUpCreateButton() {
        createButton.titleLabel?.font = .ypMedium16
        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.whiteDay, for: .normal)
        createButton.backgroundColor = .ypGray
        createButton.layer.cornerRadius = 16
    }
}
