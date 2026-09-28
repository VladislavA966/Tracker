import UIKit

final class StatisticCardView: UIView {

    private enum Layout {
        static let height: CGFloat = 90
        static let padding: CGFloat = 12
        static let cornerRadius: CGFloat = 16
        static let borderWidth: CGFloat = 1
        static let valueToTitleSpacing: CGFloat = 7
    }

    private static let gradientColors = ["#FD4C49", "#46E69D", "#007BFA"]
        .compactMap { UIColor(hexString: $0)?.cgColor }

    private let valueLabel = UILabel()
    private let titleLabel = UILabel()
    private let gradientLayer = CAGradientLayer()
    private let borderMask = CAShapeLayer()

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setUpBorder()
        setUpLabels()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setValue(_ value: Int) {
        valueLabel.text = String(value)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds

        let inset = Layout.borderWidth / 2
        borderMask.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: inset, dy: inset),
            cornerRadius: Layout.cornerRadius
        ).cgPath
    }

    // MARK: - Setup

    private func setUpBorder() {
        gradientLayer.colors = Self.gradientColors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

        borderMask.lineWidth = Layout.borderWidth
        borderMask.fillColor = nil
        borderMask.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = borderMask

        layer.addSublayer(gradientLayer)
    }

    private func setUpLabels() {
        valueLabel.font = .ypBold34
        valueLabel.textColor = .blackDay
        titleLabel.font = .ypMedium12
        titleLabel.textColor = .blackDay

        let stack = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        stack.axis = .vertical
        stack.spacing = Layout.valueToTitleSpacing
        stack.alignment = .leading

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Layout.height),
            stack.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Layout.padding
            ),
            stack.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Layout.padding
            ),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
