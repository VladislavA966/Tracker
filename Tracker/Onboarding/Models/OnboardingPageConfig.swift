import Foundation

struct OnboardingPageConfig {

    let imageName: String
    let title: String

    static let all: [OnboardingPageConfig] = [
        OnboardingPageConfig(
            imageName: AppImages.onboardingBlue,
            title: String(localized: .onboardingFirst)
        ),
        OnboardingPageConfig(
            imageName: AppImages.onboardingRed,
            title: String(localized: .onboardingSecond)
        ),
    ]
}
