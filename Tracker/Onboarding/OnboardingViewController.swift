import UIKit

final class OnboardingViewController: UIPageViewController {

    var onFinish: (() -> Void)?

    private let pages: [OnboardingPage]

    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.numberOfPages = pages.count
        control.currentPage = 0
        control.currentPageIndicatorTintColor = .blackDay
        control.pageIndicatorTintColor = .blackDay.withAlphaComponent(0.3)
        control.addTarget(
            self,
            action: #selector(onPageControlValueChanged(_:)),
            for: .valueChanged
        )
        return control
    }()

    private lazy var actionButton: UIButton = {
        let button = UIButton()
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.whiteDay, for: .normal)
        button.titleLabel?.font = .ypMedium16
        button.backgroundColor = .blackDay
        button.layer.cornerRadius = 16
        button.addTarget(
            self,
            action: #selector(onActionButtonTapped),
            for: .touchUpInside
        )
        return button
    }()

    // MARK: - Init

    init(configs: [OnboardingPageConfig] = OnboardingPageConfig.all) {
        pages = configs.map(OnboardingPage.init(config:))
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteDay
        dataSource = self
        delegate = self
        showFirstPage()
        setUpActionButton()
        setUpPageControl()
    }

    // MARK: - Setup

    private func showFirstPage() {
        guard let firstPage = pages.first else { return }
        setViewControllers([firstPage], direction: .forward, animated: false)
    }

    private func setUpActionButton() {
        view.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            actionButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),
            actionButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -50
            ),
            actionButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    private func setUpPageControl() {
        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(
                equalTo: actionButton.topAnchor,
                constant: -24
            ),
        ])
    }

    // MARK: - Actions

    @objc private func onActionButtonTapped() {
        guard let currentIndex else { return }

        let isLastPage = currentIndex == pages.count - 1
        guard !isLastPage else {
            onFinish?()
            return
        }
        showPage(at: currentIndex + 1, direction: .forward)
    }

    @objc private func onPageControlValueChanged(_ sender: UIPageControl) {
        let targetIndex = sender.currentPage
        guard let currentIndex, currentIndex != targetIndex else { return }

        showPage(
            at: targetIndex,
            direction: targetIndex > currentIndex ? .forward : .reverse
        )
    }

    // MARK: - Private

    private var currentIndex: Int? {
        guard let currentPage = viewControllers?.first else { return nil }
        return index(of: currentPage)
    }

    private func showPage(
        at index: Int,
        direction: UIPageViewController.NavigationDirection
    ) {
        setViewControllers([pages[index]], direction: direction, animated: true)
        pageControl.currentPage = index
    }

    private func index(of viewController: UIViewController) -> Int? {
        pages.firstIndex { $0 === viewController }
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let index = index(of: viewController), index > 0 else {
            return nil
        }
        return pages[index - 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let index = index(of: viewController),
            index < pages.count - 1
        else { return nil }
        return pages[index + 1]
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
            let currentPage = viewControllers?.first,
            let index = index(of: currentPage)
        else { return }
        pageControl.currentPage = index
    }
}
