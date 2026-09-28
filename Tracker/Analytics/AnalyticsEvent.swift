import Foundation

struct AnalyticsEvent {
    enum Kind: String {
        case open
        case close
        case click
    }

    enum Screen: String {
        case main = "Main"
    }

    enum Item: String {
        case addTrack = "add_track"
        case track
        case filter
        case edit
        case delete
    }

    let kind: Kind
    let screen: Screen
    let item: Item?

    var parameters: [String: String] {
        var parameters = [
            "event": kind.rawValue,
            "screen": screen.rawValue,
        ]
        parameters["item"] = item?.rawValue
        return parameters
    }

    static func open(_ screen: Screen) -> AnalyticsEvent {
        AnalyticsEvent(kind: .open, screen: screen, item: nil)
    }

    static func close(_ screen: Screen) -> AnalyticsEvent {
        AnalyticsEvent(kind: .close, screen: screen, item: nil)
    }

    static func click(_ item: Item, on screen: Screen) -> AnalyticsEvent {
        AnalyticsEvent(kind: .click, screen: screen, item: item)
    }
}
