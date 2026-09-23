import UIKit

final class PrimaryButton: UIButton {

    override var isEnabled: Bool {
        didSet { updateBackground() }
    }

    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(.whiteDay, for: .normal)
        titleLabel?.font = .ypMedium16
        layer.cornerRadius = 16
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        updateBackground()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateBackground() {
        backgroundColor = isEnabled ? .blackDay : .ypGray
    }
}
