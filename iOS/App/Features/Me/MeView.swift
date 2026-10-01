import SwiftUI
import GentleWalkCore

/// S20 Me: subscription first, then body, week, workout audio, notifications, display, Apple
/// Health, outdoor walks, help and "Delete all my data". No sliders anywhere.
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
                BodySection(limits: app.profile?.limits ?? [], onEdit: { editingBody = true })
                if app.isPro {
                    WeekSection(restDays: app.profile?.restDays ?? RestDays.freeTier) { days in
                        app.updateProfile { $0.restDays = days.map(\.rawValue).sorted(by: >) }
                    }
                }
                WorkoutAudioSection(defaults: app.defaults, musicStyles: app.music.styles)
                NotificationSection(app: app)
                DisplaySection(textSize: Binding(get: { app.textSize }, set: { app.textSize = $0 }),
                               appearance: Binding(get: { app.appearance }, set: { app.appearance = $0 }))
                HealthSection(connected: app.health.isConnected, onConnect: { Task { _ = await app.health.requestAuthorization(); app.reload() } })
                OutdoorSection(defaults: app.defaults)
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
