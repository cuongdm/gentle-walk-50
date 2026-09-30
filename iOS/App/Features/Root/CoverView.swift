import SwiftUI
import GentleWalkCore

/// What each full-screen cover shows.
struct CoverView: View {
    let app: AppModel
    let cover: AppCover

    var body: some View {
        switch cover {
        case .paywall(let trigger):
            PaywallContainer(app: app, trigger: trigger)
        case .phonePlacement(let request):
            PhonePlacementView { _ in app.placementDone(request) }
        case .preview(let model):
            PreviewCover(model: model, app: app)
        case .outdoorPrep(let request):
            OutdoorPrepView(asksLocation: app.defaults.string(forKey: "outdoorLocationChoice") == nil,
                            onRequestLocation: app.location.requestPermission,
                            onDone: { app.outdoorPrepDone(request, useLocation: $0) })
        case .preparing:
            VStack(spacing: 16) {
                ProgressView().controlSize(.large)
                Text("Getting your session ready").typeRole(.body).foregroundStyle(Palette.text)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .screenBackground()
        case .workout(let session):
            WorkoutView(session: session, name: app.profile?.name, showsMusic: app.music.showsMusicButton,
                        reviewMilestone: app.reviewMilestone(for:), onReviewAsked: app.markReviewAsked,
                        onChairMoves: session.request.place == .outdoors ? {
                            app.workoutClosed(nil)
                            app.begin(WorkoutRequest(day: PlannedDay(main: .chair, chairMoves: 0, cooldown: true),
                                                     level: .seated, intensity: session.request.intensity, place: .indoors,
                                                     limits: session.request.limits, rotationIndex: app.progress.activeDays))
                        } : nil,
                        onAgain: session.request.canReplay(isPro: app.isPro) ? { app.again(session.request) } : nil,
                        onClose: app.workoutClosed)
        case .permissions:
            PermissionsView(model: PermissionsModel(health: app.health, notifications: SystemNotificationAuthorizer(),
                                                    healthConnected: app.health.isConnected),
                            reminderTitle: Self.reminderTitle(app.profile?.reminderMoment ?? .coffee)) {
                app.cover = nil
                app.reload()
                Task { await app.notifications.reschedule() }
            }
        case .cancelGuide(let afterLifetime):
            CancelGuideView(accessUntil: app.store.renewalDate?.formatted(.dateTime.month(.abbreviated).day()),
                            isAfterLifetimePurchase: afterLifetime, onBack: { app.cover = nil })
        }
    }

    static func reminderTitle(_ moment: DailyMoment) -> String {
        switch moment {
        case .coffee: String(localized: "A gentle reminder after your morning coffee")
        case .lunch: String(localized: "A gentle reminder after lunch")
        case .tv: String(localized: "A gentle reminder during evening TV")
        case .custom: String(localized: "A gentle reminder at the time you picked")
        }
    }
}

/// S08 in the app: plans from StoreKit, the "Apple will ask you" step, then purchase.
struct PaywallContainer: View {
    let app: AppModel
    let trigger: PaywallTrigger
    @State private var model: PaywallModel?
    @State private var confirming: PlanOption?

    var body: some View {
        Group {
            if let confirming {
                BeforeAppleSheetView(isTrial: confirming.kind == .yearly && app.store.isEligibleForTrial, onContinue: {
                    Task {
                        await app.purchase(confirming, trigger: trigger)
                        self.confirming = nil
                    }
                }, onBack: { self.confirming = nil })
            } else if let model, !model.options.isEmpty {
                PaywallView(model: model, onPurchase: { confirming = $0 },
                            onRestore: { Task { await app.restorePurchases(from: trigger) } },
                            onMaybeLater: { app.paywallMaybeLater(trigger) })
            } else {
                VStack(spacing: 18) {
                    Spacer()
                    Text("Plans aren't available right now.").typeRole(.cardTitle)
                    Text("You can start with the free plan and look again later in Me.").typeRole(.body)
                    Spacer()
                    Button("Maybe later") { app.paywallMaybeLater(trigger) }.buttonStyle(.primaryAction)
                }
                .foregroundStyle(Palette.text)
                .padding(Metrics.screenMargin)
                .screenBackground()
            }
        }
        .task {
            if app.store.products.isEmpty { try? await app.store.loadProducts() }
            model = PaywallModel(options: PaywallModel.options(from: app.store.products),
                                 isEligibleForTrial: app.store.isEligibleForTrial,
                                 activeRenewingProductID: app.store.activeRenewingProductID, now: app.now(), calendar: app.calendar)
        }
    }
}

/// The preview with "Remind me at 11:40 AM", worked out when it opens (hidden when no reminder can come).
private struct PreviewCover: View {
    let model: WorkoutPreviewModel
    let app: AppModel
    @State private var remindAt: Date?

    var body: some View {
        WorkoutPreviewView(model: model, onStart: app.begin, onRemindLater: {
            app.cover = nil
            Task { await app.notifications.remindLater() }
        }, remindAt: remindAt, onClose: { app.cover = nil })
        .task { remindAt = await app.notifications.remindLaterTime() }
    }
}
