import SwiftUI
import GentleWalkCore

/// S20 Me, in groups (owner 02/10/2026: one long list of cards): the subscription; Your plan (body,
/// week, reminders); During a session (captions, sound); App (language and units, display); Phone
/// and Health (Apple Health, location); help and "Delete all my data". No sliders anywhere.
struct MeView: View {
    let app: AppModel
    @State private var confirmDelete = false
    @State private var showsPrivacy = false
    @State private var editingBody = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ScreenHeader(title: "Me")
                SubscriptionSection(entitlement: app.entitlement, renewingProductID: app.renewingProductID,
                                    renewalDate: app.renewalDate, yearlyPrice: app.price(ProductID.yearly),
                                    onSeePlans: { app.cover = .paywall(.lockedContent) },
                                    onHowToCancel: { app.cover = .cancelGuide(afterLifetime: false) })
                SettingsGroupHeader(title: "Your plan")
                if let strip = app.today?.programStrip {
                    ProgramSection(strip: strip, onOpen: {
                        app.tab = .today
                        app.todayPath = [.program]
                    }, onRestart: app.restartProgram)
                }
                BodySection(limits: app.profile?.limits ?? [], onEdit: { editingBody = true })
                WeekSection(restDays: app.isPro ? (app.profile?.restDays ?? RestDays.freeTier) : RestDays.freeTier,
                            isPro: app.isPro, onSeePlans: { app.offerPlans(.lockedContent) }) { days in
                    app.updateProfile { $0.restDays = days.map(\.rawValue).sorted(by: >) }
                }
                NotificationSection(app: app)
                SettingsGroupHeader(title: "During a session")
                WorkoutAudioSection(defaults: app.defaults, musicStyles: app.music.styles)
                SettingsGroupHeader(title: "App")
                LanguageUnitsSection(units: Binding(get: { app.units }, set: { app.units = $0 }))
                DisplaySection(textSize: Binding(get: { app.textSize }, set: { app.textSize = $0 }),
                               appearance: Binding(get: { app.appearance }, set: { app.appearance = $0 }))
                SettingsGroupHeader(title: "Phone and Health")
                HealthSection(connected: app.health.isConnected, onConnect: { Task { _ = await app.health.requestAuthorization(); app.reload() } })
                OutdoorSection(defaults: app.defaults, location: app.location)
                // The last card, its own heading (a group title would repeat "Help").
                HelpSection(onRestore: { Task { await app.restorePurchases() } }, onPrivacy: { showsPrivacy = true })
                Button("Delete all my data") { confirmDelete = true }.buttonStyle(.dangerAction)
            }
            .padding(Metrics.screenMargin)
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
        }
        .screenBackground()
        .sheet(isPresented: $showsPrivacy) { PrivacyPolicyView() }
        .sheet(isPresented: $editingBody) {
            BodyLimitsEditor(limits: app.profile?.limits ?? []) { limits in
                app.updateProfile { $0.bodyLimits = OnboardingCopy.limitOrder.filter(limits.contains).map(\.rawValue) }
            }
        }
        .fullScreenCover(isPresented: $confirmDelete) {
            DeleteDataConfirmation(onDelete: {
                confirmDelete = false
                app.eraseAllData()
            }, onCancel: { confirmDelete = false })
        }
    }
}
