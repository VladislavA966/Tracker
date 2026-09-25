import UIKit

protocol TrackerCellDelegate: AnyObject {
    func trackerCellDidTapPlus(_ cell: TrackerCell)
}

final class TrackerCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackerCollectionViewCell"

    private enum Layout {
        static let padding: CGFloat = 12
        static let cardHeight: CGFloat = 90
        static let cardCornerRadius: CGFloat = 16
        static let emojiSize: CGFloat = 24
        static let buttonSize: CGFloat = 34
        static let cardToFooterSpacing: CGFloat = 8
    }

    weak var delegate: TrackerCellDelegate?

    var previewView: UIView { cardView }

    private let cardView = UIStackView()
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    private let pinImageView = UIImageView()
    private let footerView = UIStackView()
    private let counterLabel = UILabel()
    private let addButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpHierarchy()
        setUpCardView()
        setUpEmojiLabel()
        setUpTitleLabel()
        setUpPinImageView()
        setUpFooterView()
        setUpCounterLabel()
        setUpAddButton()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with model: TrackerCellModel) {
        let tracker = model.tracker
        cardView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.name
        pinImageView.isHidden = !tracker.isPinned
        counterLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("days_count", comment: ""),
            model.completedDays
        )

        addButton.backgroundColor = tracker.color
        addButton.alpha = model.isCompleted ? 0.3 : 1
        addButton.isEnabled = model.isPlusEnabled
        addButton.setImage(
            UIImage(
                systemName: model.isCompleted ? "checkmark" : "plus",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: 11,
                    weight: .semibold
                )
            ),
            for: .normal
        )
    }

    // MARK: - Setup

    private func setUpHierarchy() {
        contentView.addSubview(cardView)
        contentView.addSubview(footerView)
        cardView.addArrangedSubview(emojiLabel)
        cardView.addArrangedSubview(titleLabel)
        cardView.addSubview(pinImageView)
        footerView.addArrangedSubview(counterLabel)
        footerView.addArrangedSubview(addButton)
    }

    private func setUpCardView() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.axis = .vertical
        cardView.alignment = .leading
        cardView.distribution = .equalSpacing
        cardView.layer.cornerRadius = Layout.cardCornerRadius
        cardView.clipsToBounds = true
        cardView.backgroundColor = .colorSelection5
        cardView.isLayoutMarginsRelativeArrangement = true
        cardView.layoutMargins = UIEdgeInsets(
            top: Layout.padding,
            left: Layout.padding,
            bottom: Layout.padding,
            right: Layout.padding
        )
    }

    private func setUpEmojiLabel() {
        emojiLabel.text = "👌"
        emojiLabel.font = .systemFont(ofSize: 14)
        emojiLabel.textAlignment = .center
        emojiLabel.backgroundColor = .white.withAlphaComponent(0.3)
        emojiLabel.layer.cornerRadius = 12
        emojiLabel.clipsToBounds = true
    }

    private func setUpTitleLabel() {
        titleLabel.text = "Какая то прикольная привычка"
        titleLabel.font = .ypMedium12
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
    }

    private func setUpPinImageView() {
        pinImageView.translatesAutoresizingMaskIntoConstraints = false
        pinImageView.image = UIImage(
            systemName: "pin.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 10)
        )
        pinImageView.tintColor = .white
        pinImageView.contentMode = .center
        pinImageView.isHidden = true
    }

    private func setUpFooterView() {
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.axis = .horizontal
        footerView.alignment = .center
        footerView.distribution = .equalSpacing
        footerView.isLayoutMarginsRelativeArrangement = true
        footerView.layoutMargins = UIEdgeInsets(
            top: 0,
            left: Layout.padding,
            bottom: 0,
            right: Layout.padding
        )
    }

    private func setUpCounterLabel() {
        counterLabel.text = "0 дней"
        counterLabel.font = .ypMedium12
        counterLabel.textColor = .label
    }

    private func setUpAddButton() {
        addButton.translatesAutoresizingMaskIntoConstraints = false
        let symbolConfig = UIImage.SymbolConfiguration(
            pointSize: 11,
            weight: .semibold
        )
        addButton.setImage(
            UIImage(systemName: "plus", withConfiguration: symbolConfig),
            for: .normal
        )
        addButton.backgroundColor = .colorSelection5
        addButton.tintColor = .white
        addButton.layer.cornerRadius = Layout.buttonSize / 2
        addButton.clipsToBounds = true
        addButton.addTarget(
            self,
            action: #selector(addButtonTapped),
            for: .touchUpInside
        )
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            cardView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            cardView.heightAnchor.constraint(
                equalToConstant: Layout.cardHeight
            ),

            emojiLabel.widthAnchor.constraint(
                equalToConstant: Layout.emojiSize
            ),
            emojiLabel.heightAnchor.constraint(
                equalToConstant: Layout.emojiSize
            ),

            titleLabel.widthAnchor.constraint(
                equalTo: cardView.layoutMarginsGuide.widthAnchor
            ),

            pinImageView.topAnchor.constraint(
                equalTo: cardView.topAnchor,
                constant: Layout.padding
            ),
            pinImageView.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -4
            ),
            pinImageView.widthAnchor.constraint(
                equalToConstant: Layout.emojiSize
            ),
            pinImageView.heightAnchor.constraint(
                equalToConstant: Layout.emojiSize
            ),

            footerView.topAnchor.constraint(
                equalTo: cardView.bottomAnchor,
                constant: Layout.cardToFooterSpacing
            ),
            footerView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            footerView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            footerView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            ),

            addButton.widthAnchor.constraint(
                equalToConstant: Layout.buttonSize
            ),
            addButton.heightAnchor.constraint(
                equalToConstant: Layout.buttonSize
            ),
        ])
    }

    // MARK: - Actions

    @objc private func addButtonTapped() {
        delegate?.trackerCellDidTapPlus(self)
    }
}
