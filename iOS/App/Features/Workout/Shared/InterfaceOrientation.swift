import SwiftUI
import UIKit

/// Full screen on a phone means the phone on its side, like other workout apps: the expand button
/// turns the screen to landscape, Exit turns it back upright. iPad keeps its own orientation.
enum InterfaceOrientation {
    @MainActor static func landscape() { request(.landscape) }
    @MainActor static func portrait() { request(.portrait) }

    @MainActor private static func request(_ mask: UIInterfaceOrientationMask) {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        // Right after launch the scene is still inactive; it can turn all the same.
        guard UIDevice.current.userInterfaceIdiom == .phone,
              let scene = scenes.first(where: { $0.activationState == .foregroundActive }) ?? scenes.first
        else { return }
        scene.requestGeometryUpdate(.iOS(interfaceOrientations: mask)) { _ in }
    }
}

extension View {
    /// Turning the phone back upright leaves full screen, so she never lands on a clip in a
    /// black frame.
    func leavesFullScreenWhenUpright(_ isOn: Binding<Bool>) -> some View {
        modifier(LeavesFullScreenWhenUpright(isOn: isOn))
    }
}

private struct LeavesFullScreenWhenUpright: ViewModifier {
    @Binding var isOn: Bool
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    func body(content: Content) -> some View {
        content.onChange(of: verticalSizeClass) { old, new in
            if old == .compact, new == .regular, horizontalSizeClass == .compact { isOn = false }
        }
    }
}

/// Round button on a clip's corner: expand, or leave full screen (56 pt target).
struct VideoCornerButton: View {
    let symbol: String
    let label: LocalizedStringResource
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .typeRole(.body)
                .fontWeight(.semibold)
                .foregroundStyle(Palette.text)
                .frame(width: 44, height: 44)
                .background(Palette.surface.opacity(0.92), in: .circle)
                // A thin edge and a soft shadow keep it visible on a white wall too (review M2).
                .overlay { Circle().strokeBorder(Palette.textMuted.opacity(0.35), lineWidth: 1) }
                .shadow(color: .black.opacity(0.14), radius: 4, y: 1)
                .frame(width: Metrics.minTouchTarget, height: Metrics.minTouchTarget)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(label))
    }

    static func expand(_ action: @escaping () -> Void) -> VideoCornerButton {
        VideoCornerButton(symbol: "arrow.up.left.and.arrow.down.right", label: "Full screen", action: action)
    }

    static func exit(_ action: @escaping () -> Void) -> VideoCornerButton {
        VideoCornerButton(symbol: "arrow.down.right.and.arrow.up.left", label: "Exit full screen", action: action)
    }
}
