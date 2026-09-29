import SwiftUI

/// Top-level view. Replaced by the onboarding / tab flow in tasks 4.13 and 6.1.
struct RootView: View {
    #if DEBUG
    /// Screenshot state from `-ScreenshotMode <state>`; nil in normal runs.
    private let captureState = CaptureHook.state(from: ProcessInfo.processInfo.arguments)
    #endif

    var body: some View {
        #if DEBUG
        if captureState == .tokens {
            TokenGalleryView()
        } else {
            PlaceholderHome()
        }
        #else
        PlaceholderHome()
        #endif
    }
}

/// Stand-in home until the real flow exists.
private struct PlaceholderHome: View {
    var body: some View {
        Text("Gentle Walk")
            .typeRole(.screenTitle)
            .foregroundStyle(Palette.text)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Palette.bg)
    }
}

#Preview {
    RootView()
}
