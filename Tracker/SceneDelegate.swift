import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private var dependencies: AppDependencies?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {

        guard let scene = (scene as? UIWindowScene) else { return }

        let dependencies =
            (UIApplication.shared.delegate as? AppDelegate)?.dependencies
            ?? AppDependencies()
        self.dependencies = dependencies

        window = UIWindow(windowScene: scene)
        window?.rootViewController =
            dependencies.hasSeenOnboarding
            ? makeMainScreen()
            : makeOnboarding()
        window?.makeKeyAndVisible()
    }

    // MARK: - Root view controllers

    private func makeOnboarding() -> UIViewController {
        let onboarding = OnboardingViewController()
        onboarding.onFinish = { [weak self] in
            self?.dependencies?.hasSeenOnboarding = true
            self?.switchToMainScreen()
        }
        return onboarding
    }

    private func makeMainScreen() -> UIViewController {
        guard let dependencies else { return UIViewController() }

        let trackersViewController = TrackersViewController(
            viewModel: dependencies.makeTrackersViewModel()
        )
        let statisticsViewController = StatisticsViewController()

        return TabBarViewController(
            trackersViewController: trackersViewController,
            statisticsViewController: statisticsViewController
        )
    }

    private func switchToMainScreen() {
        guard let window else { return }
        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve
        ) {
            window.rootViewController = self.makeMainScreen()
        }
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
