import SwiftUI
import UIKit

/// Me → Display → Appearance: Auto (follows the iPhone, the default), Light or Dark (owner
/// 01/10/2026). Set on the app's windows, so sheets and full-screen covers follow too, and going
/// back to Auto really returns to the system setting (`preferredColorScheme(nil)` can stick).
enum AppearanceChoice: String, CaseIterable, Identifiable, Sendable {
    case auto, light, dark
    var id: String { rawValue }

    static let defaultsKey = "appearance"

    init(defaults: UserDefaults = .standard) {
        self = defaults.string(forKey: Self.defaultsKey).flatMap(AppearanceChoice.init) ?? .auto
    }

    func save(to defaults: UserDefaults = .standard) {
        defaults.set(rawValue, forKey: Self.defaultsKey)
    }

    var title: LocalizedStringResource {
        switch self {
        case .auto: "Auto"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var interfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .auto: .unspecified
        case .light: .light
        case .dark: .dark
        }
    }

    /// Applies the choice to every window of the app.
    @MainActor func apply() {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows { window.overrideUserInterfaceStyle = interfaceStyle }
        }
    }
}
