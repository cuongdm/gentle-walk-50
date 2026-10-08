import SwiftUI

/// Top-level view: onboarding until a profile exists, then the four tabs; covers on top.
struct RootView: View {
    let notificationDelegate: NotificationDelegate

    #if DEBUG
    /// Screenshot state from `-ScreenshotMode <state>`; nil in normal runs.
    private let captureState = CaptureHook.state(from: ProcessInfo.processInfo.arguments)
    #endif

    @State private var app: AppModel?

    var body: some View {
        #if DEBUG
        if let captureState {
            CaptureRouter(state: captureState)
        } else {
            appBody
        }
        #else
        appBody
        #endif
    }

    @ViewBuilder private var appBody: some View {
        Group {
            if let app {
                AppRootView(app: app)
            } else {
                Palette.bg.ignoresSafeArea()
            }
        }
        .task {
            guard app == nil else { return }
            let model = AppModel.live()
            app = model
            notificationDelegate.attach(model)
            await model.launch()
        }
    }
}

struct AppRootView: View {
    @Bindable var app: AppModel
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if app.onboardingDone {
                MainTabView(app: app)
            } else {
                OnboardingView(flow: app.onboarding, voiceSource: app.voiceSource, voiceLines: app.content.voiceLines,
                               onRestore: { Task { await app.restorePurchases() } },
                               onFinished: app.finishOnboarding)
            }
        }
        .fullScreenCover(item: $app.cover) { cover in
            CoverView(app: app, cover: cover)
                .textSizeOverride(app.textSize)
                .storeNoticeAlert(app)
        }
        .textSizeOverride(app.textSize)
        .storeNoticeAlert(app)
        // A new day while the app sat in the background, or at midnight: rebuild Today (review I4).
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { app.sceneBecameActive() }
        }
        // Light or Dark from Me → Display (Auto leaves the iPhone's setting).
        .onAppear { app.appearance.apply() }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged).receive(on: RunLoop.main)) { _ in
            app.sceneBecameActive()
        }
    }
}

#if DEBUG
/// Routes a capture state to the screen that draws it.
struct CaptureRouter: View {
    let state: CaptureState

    var body: some View {
        // "-xxl" states show the largest accessibility text; every other state keeps the simulator's
        // own text size, so "<state>@xxl" in capture_states.sh is captured large (review M10).
        // "-dark" states draw dark whatever the simulator's appearance (they matched the light shots; review C).
        Group {
            if let size = Self.pinnedTypeSize(for: state) {
                scene.dynamicTypeSize(size)
            } else {
                scene
            }
        }
        .preferredColorScheme(Self.pinnedColorScheme(for: state))
    }

    static func pinnedColorScheme(for state: CaptureState) -> ColorScheme? {
        state.rawValue.hasSuffix("-dark") ? .dark : nil
    }

    static func pinnedTypeSize(for state: CaptureState) -> DynamicTypeSize? {
        state.rawValue.hasSuffix("-xxl") ? .accessibility3 : nil
    }

    @ViewBuilder private var scene: some View {
        switch state {
        case .tokens:
            TokenGalleryView()
        default:
            if AppCaptureScene.handles(state) {
                AppCaptureScene(state: state)
            } else {
                WorkoutCaptureScene(state: state, content: AppContent.bundle)
            }
        }
    }
}
#endif
