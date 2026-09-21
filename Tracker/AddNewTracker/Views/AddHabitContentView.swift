import UIKit

final class AddHabitContentView: UIView {
    let scrollView = UIScrollView()
    let contentStack = UIStackView()
    let textField = AddHabitTextField()
    let buttonsRow = ButtonsRow()
    let optionTableView = OptionsTableView()
    let emojisCollectionView = SelfSizingCollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    let errorLabel = ErrorLabel()
    let emojiCollectionHeader = AddTrackerHeaderLabel(
        frame: .zero,
        title: "Emoji"
    )
    let colorsCollectionView = SelfSizingCollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    let colorCollectionHeader = AddTrackerHeaderLabel(
        frame: .zero,
        title: "Цвет"
    )

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.directionalLayoutMargins = .init(
            top: 24,
            leading: 16,
            bottom: 24,
            trailing: 16
        )

        contentStack.addArrangedSubview(textField)
        contentStack.addArrangedSubview(errorLabel)
        contentStack.addArrangedSubview(optionTableView)
        contentStack.addArrangedSubview(emojiCollectionHeader)
        contentStack.addArrangedSubview(emojisCollectionView)
        contentStack.addArrangedSubview(colorCollectionHeader)
        contentStack.addArrangedSubview(colorsCollectionView)
        [scrollView, buttonsRow].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        let content = scrollView.contentLayoutGuide
        let frame = scrollView.frameLayoutGuide

        NSLayoutConstraint.activate([
            buttonsRow.leadingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
            buttonsRow.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor,
                constant: -16
            ),
            buttonsRow.bottomAnchor.constraint(
                equalTo: safeAreaLayoutGuide.bottomAnchor
            ),

            scrollView.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor
            ),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(
                equalTo: buttonsRow.topAnchor,
                constant: -16
            ),

            contentStack.topAnchor.constraint(equalTo: content.topAnchor),
            contentStack.leadingAnchor.constraint(
                equalTo: content.leadingAnchor
            ),
            contentStack.trailingAnchor.constraint(
                equalTo: content.trailingAnchor
            ),
            contentStack.bottomAnchor.constraint(equalTo: content.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: frame.widthAnchor),
        ])
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

