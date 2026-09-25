import Foundation

struct OnboardingPageConfig {

    let imageName: String
    let title: String

    static let all: [OnboardingPageConfig] = [
        OnboardingPageConfig(
            imageName: AppImages.onboardingBlue,
            title: "Отслеживайте только то, что хотите"
        ),
        OnboardingPageConfig(
            imageName: AppImages.onboardingRed,
            title: "Даже если это не литры воды и йога"
        ),
    ]
}
