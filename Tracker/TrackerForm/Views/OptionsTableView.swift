import UIKit

final class OptionsTableView: UITableView {
    static let cellIdentifier = "cell"

    override init(frame: CGRect = .zero, style: UITableView.Style = .plain) {
        super.init(frame: frame, style: style)
        layer.cornerRadius = 16
        isScrollEnabled = false
        layer.masksToBounds = true
        rowHeight = AppConstants.optionRowHeight
        tableHeaderView = UIView(
            frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude)
        )
        tableFooterView = UIView(
            frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude)
        )
        register(UITableViewCell.self, forCellReuseIdentifier: Self.cellIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
