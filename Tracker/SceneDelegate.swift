import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {

        guard let scene = (scene as? UIWindowScene) else { return }

        let dependencies =
            (UIApplication.shared.delegate as? AppDelegate)?.dependencies
            ?? AppDependencies()

        let trackersViewController = TrackersViewController(
            viewModel: dependencies.makeTrackersViewModel()
        )
        let statisticsViewController = StatisticsViewController()

        window = UIWindow(windowScene: scene)
        window?.rootViewController = TabBarViewController(
            trackersViewController: trackersViewController,
            statisticsViewController: statisticsViewController
        )
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {

    }

    func sceneDidBecomeActive(_ scene: UIScene) {

    }

    func sceneWillResignActive(_ scene: UIScene) {

    }

    func sceneWillEnterForeground(_ scene: UIScene) {

    }

    func sceneDidEnterBackground(_ scene: UIScene) {

    }

}
