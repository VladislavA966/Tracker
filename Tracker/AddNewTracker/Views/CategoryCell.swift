import UIKit

final class CategoryCell: UITableViewCell {

    static let reuseIdentifier = "CategoryCell"

    private let titleLabel = UILabel()
    private let checkmarkImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .backgroundDay
        selectionStyle = .none
        setUpTitleLabel()
        setUpCheckmarkImageView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(with model: CategoryCellModel) {
        titleLabel.text = model.title
        checkmarkImageView.isHidden = !model.isSelected
    }

    // MARK: - Setup

    private func setUpTitleLabel() {
        titleLabel.font = .ypRegular17
        titleLabel.textColor = .blackDay

        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            titleLabel.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
        ])
    }

    private func setUpCheckmarkImageView() {
        checkmarkImageView.image = UIImage(systemName: "checkmark")
        checkmarkImageView.tintColor = .ypBlue
        checkmarkImageView.contentMode = .scaleAspectFit

        contentView.addSubview(checkmarkImageView)
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checkmarkImageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),
            checkmarkImageView.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
            checkmarkImageView.leadingAnchor.constraint(
                greaterThanOrEqualTo: titleLabel.trailingAnchor,
                constant: 8
            ),
        ])
    }
}
