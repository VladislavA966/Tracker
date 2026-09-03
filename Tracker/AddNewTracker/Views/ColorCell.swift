import UIKit

final class ColorCell: UICollectionViewCell {
    static let reuseIdentifier = "ColorCell"
    let colorView = UIView()

    var color: UIColor? {
        didSet {
            colorView.backgroundColor = color
            updateBorder()
        }
    }

    override var isSelected: Bool {
        didSet {
            updateBorder()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(colorView)
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.layer.cornerRadius = 8
        contentView.layer.cornerRadius = 14
        contentView.layer.borderWidth = 3
        contentView.layer.borderColor = UIColor.clear.cgColor
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateBorder() {
        contentView.layer.borderColor =
            isSelected
            ? color?.withAlphaComponent(0.3).cgColor
            : UIColor.clear.cgColor
    }
}
