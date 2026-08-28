import UIKit

final class TabBarViewController: UITabBarController {
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setUpAppearance()
        let mainTrackerVC = TrackersViewController()
        let trackerNav = UINavigationController(rootViewController: mainTrackerVC)
        trackerNav.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: AppImages.trackerTab)?
                .withRenderingMode(.alwaysTemplate),
            tag: 0
        )
        let statisticsVC = StatisticsViewController()
        statisticsVC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: AppImages.statisticsTab)?
                .withRenderingMode(.alwaysTemplate),
            tag: 1
        )
        
        viewControllers = [trackerNav, statisticsVC]
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
