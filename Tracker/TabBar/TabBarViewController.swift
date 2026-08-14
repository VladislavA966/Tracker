import UIKit

final class TabBarViewController: UITabBarController {
    override func viewDidLoad() {
        
        ///TODO: Актуализировать дизайн табов
        super.viewDidLoad()
        let mainTrackerVC = TrackersViewController()
        let trackerNav = UINavigationController(rootViewController: mainTrackerVC)
        trackerNav.tabBarItem = UITabBarItem(
            title: "Трекер",
            image: UIImage(named: AppImages.trackerTab),
            tag: 0
        )
        let statisticsVC = StatisticsViewController()
        statisticsVC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: AppImages.statisticsTab),
            tag: 1
        )
        
        viewControllers = [trackerNav, statisticsVC]

    }
}
