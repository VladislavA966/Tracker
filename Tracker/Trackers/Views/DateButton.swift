import UIKit

final class DateButton: UIButton {

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()

    init() {
        super.init(frame: .zero)
        var configuration = UIButton.Configuration.plain()
        configuration.baseForegroundColor = .datePickerText
        configuration.background.backgroundColor = .datePickerBackground
        configuration.background.cornerRadius = 8
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 6,
            leading: 6,
            bottom: 6,
            trailing: 6
        )
        self.configuration = configuration
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDate(_ date: Date) {
        configuration?.attributedTitle = AttributedString(
            Self.formatter.string(from: date),
            attributes: AttributeContainer([.font: UIFont.ypRegular17])
        )
    }
}
