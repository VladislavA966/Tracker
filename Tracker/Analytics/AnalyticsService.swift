import AppMetricaCore
import Foundation

final class AnalyticsService {

    static let shared = AnalyticsService()

    private static let eventName = "ui_event"

    private init() {}

    func activate(apiKey: String) {
        guard let configuration = AppMetricaConfiguration(apiKey: apiKey) else {
            print("[Analytics] AppMetrica не активирована: невалидный API key")
            return
        }
        AppMetrica.activate(with: configuration)
    }

    func report(_ event: AnalyticsEvent) {
        let parameters = event.parameters
        print("[Analytics] \(Self.eventName) \(parameters)")
        AppMetrica.reportEvent(
            name: Self.eventName,
            parameters: parameters,
            onFailure: { error in
                print("[Analytics] ошибка отправки: \(error.localizedDescription)")
            }
        )
    }
}
