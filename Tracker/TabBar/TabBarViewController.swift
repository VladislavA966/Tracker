import UIKit

final class TabBarViewController: UITabBarController {

    private let trackersViewController: UIViewController
    private let statisticsViewController: UIViewController

    init(
        trackersViewController: UIViewController,
        statisticsViewController: UIViewController
    ) {
        self.trackersViewController = trackersViewController
        self.statisticsViewController = statisticsViewController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpAppearance()

        let trackerNav = UINavigationController(
            rootViewController: trackersViewController
        )
        trackerNav.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: AppImages.trackerTab)?
                .withRenderingMode(.alwaysTemplate),
            tag: 0
        )
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: AppImages.statisticsTab)?
                .withRenderingMode(.alwaysTemplate),
            tag: 1
        )

        viewControllers = [trackerNav, statisticsViewController]
    }

    private func setUpAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .whiteDay
        appearance.shadowColor = .ypGray

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = .ypGray
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.ypGray,
            .font: UIFont.ypMedium10,
        ]
        itemAppearance.selected.iconColor = .ypBlue
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.ypBlue,
            .font: UIFont.ypMedium10,
        ]
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .ypBlue
        tabBar.unselectedItemTintColor = .ypGray
    }
}
