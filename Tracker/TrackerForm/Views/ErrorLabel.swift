import UIKit

final class ErrorLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        text = "Ограничение \(AppConstants.trackerNameValidationMaxLength) символов"
        font = .ypMedium12
        textColor = .ypRed
        textAlignment = .center
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
