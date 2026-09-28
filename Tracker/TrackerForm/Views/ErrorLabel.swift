import UIKit

final class ErrorLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        text = String(
            localized: .formNameLimit(AppConstants.trackerNameValidationMaxLength)
        )
        font = .ypMedium12
        textColor = .ypRed
        textAlignment = .center
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
