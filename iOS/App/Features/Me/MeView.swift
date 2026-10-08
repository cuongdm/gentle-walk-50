import SwiftUI
import GentleWalkCore

/// S20 Me, in groups of iOS-style rows (plan 08/10/2026 task 3.4, `claude-design/Me.dc.html`): the
/// subscription card; Your plan (12 weeks, goal, body, moves set aside, rest days, notifications); During a
/// session; App; Phone and Health; Help with Acknowledgements; "Delete all my data". Each row is an icon
/// chip, the words, the current value and ›, and opens its own screen (`MeRoute`) holding the card that
/// used to sit here. No sliders anywhere.
struct MeView: View {
    let app: AppModel
    @State private var confirmDelete = false
    @State private var showsPrivacy = false
    @State private var editingGoal = false
    // The same stores the Sound and Outdoor screens switch, so the row values follow them.
    @AppStorage("captionsOn") private var captionsOn = true
    @AppStorage(OutdoorLocationChoice.defaultsKey) private var outdoorChoice = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ScreenHeader(title: "Me")
                SubscriptionSection(entitlement: app.entitlement, renewingProductID: app.renewingProductID,
                                    renewalDate: app.renewalDate, yearlyPrice: app.price(.yearly),
                                    onSeePlans: { app.cover = .paywall(.lockedContent) },
                                    onHowToCancel: { app.cover = .cancelGuide(afterLifetime: false) })
                SettingsGroupHeader(title: "Your plan")
                MeRowGroup {
                    if let strip = app.today?.programStrip {
                        MeNavigationRow(title: "Your 12 weeks", icon: MeRow.program.icon, value: strip.title, route: .program)
                    }
                    let goal = app.profile?.goal ?? .notSure
                    MeNavigationRow(title: "Your goal", icon: OnboardingCopy.icon(goal),
                                    value: String(localized: OnboardingCopy.title(goal)), action: { editingGoal = true })
                    MeNavigationRow(title: "Your body", icon: MeRow.body.icon, value: bodyValue, route: .body)
                    let setAside = app.setAsideMoves
                    if !setAside.isEmpty {
                        MeNavigationRow(title: "Moves set aside", icon: MeRow.setAside.icon,
                                        value: setAside.map(\.name).formatted(.list(type: .and)), route: .setAside)
                    }
                    MeNavigationRow(title: "Rest days", icon: MeRow.restDays.icon, value: restDaysValue, route: .restDays)
                    MeNavigationRow(title: "Notifications", icon: MeRow.notifications.icon, value: reminderValue,
                                    route: .notifications)
                }
                #if DEBUG
                // Not in screenshots (the capture hook is the only launch convention).
                if CaptureHook.state(from: ProcessInfo.processInfo.arguments) == nil {
                    PersonalisationCountersCard(counters: app.personalisationCounters())
                }
                #endif
                SettingsGroupHeader(title: "During a session")
                MeRowGroup {
                    MeNavigationRow(title: "Sound and captions", icon: MeRow.sound.icon, value: captionsValue, route: .sound)
                }
                SettingsGroupHeader(title: "App")
                MeRowGroup {
                    MeNavigationRow(title: "Language and units", icon: MeRow.languageUnits.icon,
                                    value: "\(AppLanguage.current.nativeName) · \(String(localized: app.units.distance.symbol))",
                                    route: .languageUnits)
                    MeNavigationRow(title: "Display", icon: MeRow.display.icon, value: String(localized: app.appearance.title),
                                    route: .display)
                }
                SettingsGroupHeader(title: "Phone and Health")
                MeRowGroup {
                    MeNavigationRow(title: "Apple Health", icon: MeRow.health.icon, value: onOff(app.health.isConnected),
                                    route: .health)
                    MeNavigationRow(title: "Outdoor walks", icon: MeRow.outdoors.icon, value: outdoorValue, route: .outdoors)
                }
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
        .sheet(isPresented: $editingGoal) {
            GoalEditor(goal: app.profile?.goal ?? .notSure) { goal in
                app.updateProfile { $0.goals = [goal.rawValue] }
            }
        }
        .fullScreenCover(isPresented: $confirmDelete) {
            DeleteDataConfirmation(onDelete: {
                confirmDelete = false
                app.eraseAllData()
            }, onCancel: { confirmDelete = false })
        }
    }

    // The value at the end of each row: what is set now, in a few words.

    /// "Easy on knees", "Easy on knees +2", or "Nothing to go easy on".
    private var bodyValue: String {
        let limits = OnboardingCopy.limitOrder.filter((app.profile?.limits ?? []).contains)
        guard let first = limits.first else { return String(localized: "Nothing to go easy on") }
        let name = String(localized: OnboardingCopy.summary(first))
        return limits.count == 1 ? name : String(localized: "\(name) +\(limits.count - 1)")
    }

    /// "Sat, Sun".
    private var restDaysValue: String {
        let order: [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        return order.filter(app.restDays.contains)
            .map { Calendar.current.shortWeekdaySymbols[$0.rawValue - 1] }
            .formatted(.list(type: .and, width: .narrow))
    }

    /// "8:30 AM", or "Off".
    private var reminderValue: String {
        guard app.notificationSettings.walkReminders else { return String(localized: "Off") }
        return DailyMomentPicker.time((app.profile ?? .empty).reminderMinutes)
    }

    private var captionsValue: String {
        captionsOn ? String(localized: "Captions on") : String(localized: "Captions off")
    }

    private var outdoorValue: String {
        outdoorChoice == "location"
            ? String(localized: "Map and distance") : String(localized: "Steps only")
    }

    private func onOff(_ on: Bool) -> String { on ? String(localized: "On") : String(localized: "Off") }
}
