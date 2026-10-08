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
            OutdoorPrepView(asksLocation: OutdoorLocationChoice.asks(in: app.defaults),
                            onRequestLocation: { await app.location.requestPermissionAndWait() },
                            onDone: { app.outdoorPrepDone(request, useLocation: $0) },
                            onClose: { app.cover = nil })
        case .preparing:
            VStack(spacing: 16) {
                ProgressView().controlSize(.large)
                Text("Getting your session ready").typeRole(.body).foregroundStyle(Palette.text)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .screenBackground()
        case .workout(let session):
            WorkoutView(session: session, name: app.profile?.name, showsMusic: app.music.showsMusicButton,
                        healthConnected: app.health.isConnected,
                        reviewMilestone: app.reviewMilestone(for:), onReviewAsked: app.markReviewAsked,
                        onChairMoves: session.request.place == .outdoors ? {
                            app.workoutClosed(session.completionResult)
                            app.afterOneTimeScreens {
                                app.begin(.chairMovesAfterOutdoor(limits: session.request.limits,
                                                                  rotationIndex: app.progress.activeDays))
                            }
                        } : nil,
                        onOpenPostcard: { stop in
                            let journeyID = session.completionResult?.journeyID ?? app.journey.journeyID
                            app.afterOneTimeScreens {
                                app.tab = .journey
                                app.journeyPath = [.postcard(journeyID: journeyID, stopID: stop.id)]
                            }
                        },
                        onAgain: session.request.canReplay(isPro: app.isPro) ? { app.again(session.request) } : nil,
                        onNotYet: {
                            app.workoutClosed(nil)
                            if session.request.isFirstWalk { Task { await app.offerReminderAfterNotYet() } }
                        },
                        // After the permission screens (S16a/b) when they show: the invite never blocks the permissions.
                        onSelfCheck: { app.afterOneTimeScreens { app.openSelfCheck() } },
                        onSelfCheckLater: app.selfCheckLater,
                        onClose: app.workoutClosed)
        case .permissions(let ask):
            PermissionsCover(app: app, ask: ask)
        case .reminderOffer:
            ReminderOfferCover(app: app)
        case .cancelGuide(let afterLifetime):
            CancelGuideView(accessUntil: app.store.renewalDate?.formatted(.dateTime.month(.abbreviated).day()),
                            isAfterLifetimePurchase: afterLifetime, onBack: app.oneTimeScreenClosed)
        case .selfCheck(let model):
            SelfCheckFlowView(model: model, onNotToday: app.selfCheckLater, onSave: { app.saveSelfCheck(model) },
                              onClose: app.closeSelfCheck)
        case .weeklyCheckIn:
            WeeklyCheckInView(onSave: { app.saveWeeklyCheckIn(effort: $0, better: $1) },
                              onSkip: { app.saveWeeklyCheckIn(effort: nil, better: nil) })
        case .programFinished:
            ProgramFinishedView(summary: app.programFinishedSummary(), name: app.profile?.name,
                                onRestart: app.restartProgram, onKeepRoutine: app.keepRoutine,
                                onChangeGoal: {
                                    app.cover = nil
                                    app.tab = .me
                                })
        }
    }
}

/// S08 in the app: plans from the store (RevenueCat), the "Apple will ask you" step, then purchase.
/// No plans (offline, or a build with no store): a calm note, "Try again" and "Maybe later", never an
/// empty or broken screen.
struct PaywallContainer: View {
    let app: AppModel
    let trigger: PaywallTrigger
    @State private var model: PaywallModel?
    @State private var confirming: PlanOption?
    @State private var isLoading = true

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
            } else if isLoading {
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .screenBackground()
            } else {
                PlansUnavailableView(onTryAgain: { Task { await load(retry: true) } },
                                     onMaybeLater: { app.paywallMaybeLater(trigger) })
            }
        }
        .task { await load(retry: false) }
    }

    /// Reads the plans (again on "Try again") and builds the paywall from them.
    private func load(retry: Bool) async {
        isLoading = true
        if retry || app.store.offers.isEmpty { try? await app.store.loadProducts() }
        model = PaywallModel(options: PaywallModel.options(from: app.store.offers),
                             isEligibleForTrial: app.store.isEligibleForTrial, trialDays: app.store.trialDays,
                             activeRenewingProductID: app.store.activeRenewingProductID, goal: app.profile?.goal ?? .notSure,
                             now: app.now(), calendar: app.calendar)
        isLoading = false
    }
}

/// "Plans aren't available right now." with a way to try again and a way on: offline, the store not
/// answering, or a build without a store. The free plan keeps working either way.
struct PlansUnavailableView: View {
    let onTryAgain: () -> Void
    let onMaybeLater: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            Text("Plans aren't available right now.").typeRole(.cardTitle)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Text("You can start with the free plan and look again later in Me.").typeRole(.body)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            Button("Try again", action: onTryAgain).buttonStyle(.secondaryAction)
            Button("Maybe later", action: onMaybeLater).buttonStyle(.primaryAction)
        }
        .foregroundStyle(Palette.text)
        .padding(Metrics.screenMargin)
        .readableColumn()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .screenBackground()
    }
}

/// The preview with "Remind me at 11:40 AM", worked out when it opens (hidden when no reminder can come).
private struct PreviewCover: View {
    let model: WorkoutPreviewModel
    let app: AppModel
    @State private var remindAt: Date?

    var body: some View {
        WorkoutPreviewView(model: model, onStart: app.beginFromPreview, onRemindLater: {
            app.cover = nil
            Task { await app.notifications.remindLater() }
        }, remindAt: remindAt, onClose: { app.cover = nil })
        .task { remindAt = await app.notifications.remindLaterTime() }
    }
}

/// S16a/S16b with one model kept across both steps and while the reminder time changes (the profile
/// update redraws the cover).
private struct PermissionsCover: View {
    let app: AppModel
    let ask: PermissionAsk
    @State private var model: PermissionsModel

    init(app: AppModel, ask: PermissionAsk) {
        self.app = app
        self.ask = ask
        _model = State(initialValue: PermissionsModel(health: app.health, notifications: SystemNotificationAuthorizer(),
                                                      healthConnected: app.health.isConnected))
    }

    var body: some View {
        PermissionStepView(ask: ask, model: model,
                           moment: app.profile?.reminderMoment ?? .coffee,
                           minutes: app.profile?.reminderMinutes ?? DailyMoment.coffee.suggestedMinutes,
                           onReminderTime: { moment, minutes in
                               app.updateProfile {
                                   $0.reminderMoment = moment.rawValue
                                   $0.reminderMinutes = minutes
                               }
                           },
                           onDone: { app.permissionStepDone(ask) },
                           onBack: ask == .health ? { app.cover = .permissions(.reminders) } : nil)
        .id(ask)
        .task { await model.readReminders() }
    }
}

/// After "Not yet" on the First Walk: a reminder for the walk still waiting (owner 02/10/2026: the
/// people most likely to drift away got none, reminders were asked only after a first session).
private struct ReminderOfferCover: View {
    let app: AppModel
    @State private var asking = false
    @State private var isShort = false
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // 96 pt; none on an iPhone SE, where it pushed the reminder time under "Remind me" (review A,
                // 09/10/2026: she must see the time she agrees to).
                if !isShort {
                    ArtImage(art: .momentFriends, height: 96, fallbackSymbol: "bell.fill")
                        .accessibilityHidden(true)
                }
                // The subtitle says it: no second question above the moments (task 1.13).
                ScreenHeader(title: "Want a reminder?", subtitle: "Your first walk waits on Today. We can nudge you once a day.")
                DailyMomentPicker(moment: app.profile?.reminderMoment ?? .coffee,
                                  minutes: app.profile?.reminderMinutes ?? DailyMoment.coffee.suggestedMinutes,
                                  onChoose: { moment in update(moment, moment.suggestedMinutes) },
                                  onStep: { step in
                                      update(app.profile?.reminderMoment ?? .coffee,
                                             ReminderTime.step(app.profile?.reminderMinutes ?? DailyMoment.coffee.suggestedMinutes, by: step))
                                  },
                                  onSet: { minutes in update(app.profile?.reminderMoment ?? .coffee, minutes) },
                                  showsQuestion: false)
                // At accessibility sizes the buttons end the page (a pinned bar took half the screen).
                if typeSize.isAccessibilitySize { actions }
            }
            .padding(Metrics.screenMargin)
            .readableColumn()
        }
        .pinnedActions(!typeSize.isAccessibilitySize) { actions }
        .onShortHeightChange { isShort = $0 }
        .screenBackground()
    }

    @ViewBuilder private var actions: some View {
            Button("Remind me") {
                guard !asking else { return }
                asking = true
                Task {
                    _ = await SystemNotificationAuthorizer().requestAuthorization()
                    await app.notifications.reschedule()
                    app.cover = nil
                }
            }
            .buttonStyle(.primaryAction)
            Button("No thanks") { app.cover = nil }
                .buttonStyle(.textLink)
                .frame(maxWidth: .infinity)
    }

    private func update(_ moment: DailyMoment, _ minutes: Int) {
        app.updateProfile {
            $0.reminderMoment = moment.rawValue
            $0.reminderMinutes = minutes
        }
    }
}

