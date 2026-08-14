import UIKit

final class EmptyView: UIStackView {
    let imageView = UIImageView()
    let label = UILabel()

    init(title: String, imageName: String) {
        super.init(frame: .zero)
        imageView.image = UIImage(named: imageName)
        label.text = "Что будем отслеживать?"
        label.font = .ypMedium12
        addArrangedSubview(imageView)
        addArrangedSubview(label)
        axis = .vertical
        alignment = .center
        spacing = 8
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
