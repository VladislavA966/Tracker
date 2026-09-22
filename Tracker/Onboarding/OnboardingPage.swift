import UIKit

final class OnboardingPage: UIViewController {

    private let config: OnboardingPageConfig

    private let backgroundImageView = UIImageView()
    private let titleLabel = UILabel()

    // MARK: - Init

    init(config: OnboardingPageConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteDay
        setUpBackgroundImageView()
        setUpTitleLabel()
    }

    // MARK: - Setup

    private func setUpBackgroundImageView() {
        backgroundImageView.image = UIImage(named: config.imageName)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true

        view.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),
            backgroundImageView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            backgroundImageView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
        ])
    }

    private func setUpTitleLabel() {
        titleLabel.text = config.title
        titleLabel.font = .ypBold32
        titleLabel.textColor = .blackDay
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            titleLabel.centerYAnchor.constraint(
                equalTo: view.centerYAnchor,
                constant: 60
            ),
        ])
    }
}
