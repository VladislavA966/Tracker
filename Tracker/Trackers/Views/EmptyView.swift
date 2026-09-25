import UIKit

final class EmptyView: UIStackView {
    let imageView = UIImageView()
    let label = UILabel()

    init(title: String, imageName: String) {
        super.init(frame: .zero)
        configure(title: title, imageName: imageName)
        label.font = .ypMedium12
        label.textAlignment = .center
        addArrangedSubview(imageView)
        addArrangedSubview(label)
        axis = .vertical
        alignment = .center
        spacing = 8
    }

    func configure(title: String, imageName: String) {
        imageView.image = UIImage(named: imageName)
        label.text = title
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
