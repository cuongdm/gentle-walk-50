import SwiftUI

/// Me → Display → Text size with A− / A+ buttons (no slider). Step 0 follows the system setting;
/// other steps pin the app's Dynamic Type size.
struct TextSizeOverride: Equatable {
    static let defaultsKey = "textSizeStep"
    static let minStep = -1
    static let maxStep = 3

    private(set) var step: Int

    init(step: Int) {
        self.step = min(Self.maxStep, max(Self.minStep, step))
    }

    init(defaults: UserDefaults = .standard) {
        self.init(step: defaults.integer(forKey: Self.defaultsKey))
    }

    /// nil = the system size.
    var dynamicTypeSize: DynamicTypeSize? {
        switch step {
        case ..<0: .medium
        case 0: nil
        case 1: .xLarge
        case 2: .xxLarge
        default: .xxxLarge
        }
    }

    mutating func increase() { step = min(Self.maxStep, step + 1) }
    mutating func decrease() { step = max(Self.minStep, step - 1) }

    func save(to defaults: UserDefaults = .standard) {
        defaults.set(step, forKey: Self.defaultsKey)
    }
}

extension View {
    /// Applies the user's text size choice on top of the system setting.
    @ViewBuilder func textSizeOverride(_ override: TextSizeOverride) -> some View {
        if let size = override.dynamicTypeSize { dynamicTypeSize(size) } else { self }
    }
}
