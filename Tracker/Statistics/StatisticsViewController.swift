import UIKit

final class StatisticsViewController: UIViewController {

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let cardsTopInset: CGFloat = 77
    }

    private let viewModel: StatisticsViewModel

    private let completedCard = StatisticCardView(title: String(localized: .statisticsCompleted))
    private let emptyView = EmptyView(
        title: String(localized: .statisticsEmpty),
        imageName: AppImages.statisticsEmptyImage
    )

    // MARK: - Init

    init(viewModel: StatisticsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteDay
        setUpNavigationBar()
        setUpCard()
        setUpEmptyView()
        setUpBindings()
        viewModel.viewDidLoad()
    }

    // MARK: - Bindings

    private func setUpBindings() {
        viewModel.onCompletedCountChange = { [weak self] count in
            self?.completedCard.setValue(count)
            self?.updateEmptyState()
        }
    }

    // MARK: - Setup

    private func updateEmptyState() {
        let isEmpty = viewModel.isEmpty
        emptyView.isHidden = !isEmpty
        completedCard.isHidden = isEmpty
    }

    private func setUpNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = String(localized: .statisticsTitle)
        navigationItem.largeTitleDisplayMode = .always
    }

    private func setUpCard() {
        view.addSubview(completedCard)
        completedCard.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            completedCard.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Layout.cardsTopInset
            ),
            completedCard.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Layout.horizontalInset
            ),
            completedCard.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Layout.horizontalInset
            ),
        ])
    }

    private func setUpEmptyView() {
        view.addSubview(emptyView)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
