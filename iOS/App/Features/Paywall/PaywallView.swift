import SwiftUI

/// S08 Paywall. Money is shown plainly: the billing date, the billed price as the biggest price,
/// Restore · Terms · Privacy and "Maybe later" always on screen. No countdowns, no struck-through
/// prices, no before/after pictures.
struct PaywallView: View {
    @Bindable var model: PaywallModel
    let onPurchase: (PlanOption) -> Void
    let onRestore: () -> Void
    let onMaybeLater: () -> Void
    @State private var showsPrivacy = false
    @Environment(\.dynamicTypeSize) private var typeSize

    /// At normal text sizes the button, terms and links stay pinned at the bottom, so they are
    /// visible without scrolling even on the smallest iPhone (3.1.1, 3.1.2). At accessibility
    /// sizes they scroll with the page, so they never cover it.
    private var pinsFooter: Bool { !typeSize.isAccessibilitySize }

    private var footer: some View {
        PaywallLegalFooter(disclosure: model.disclosure, buttonTitle: model.buttonTitle,
                           onContinue: { if let selected = model.selected { onPurchase(selected) } },
                           onMaybeLater: onMaybeLater, onRestore: onRestore, onPrivacy: { showsPrivacy = true })
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ScreenHeader(title: model.title)
                if model.showsTrial, let yearly = model.yearly {
                    TrialTimelineView(billingDate: model.billingDateText, price: yearly.price)
                }
                VStack(spacing: Metrics.touchSpacing) {
                    ForEach(model.options) { option in
                        PlanOptionCard(option: option, isSelected: model.selectedID == option.id,
                                       showsTrialNote: option.kind == .yearly && model.isEligibleForTrial,
                                       renewingWarning: option.kind == .lifetime && model.showsRenewingWarning) {
                            model.selectedID = option.id
                        }
                    }
                }
                IncludedList()
                Text("Cancel anytime in Settings. Deleting the app doesn't cancel.")
                    .typeRole(.body)
                    .foregroundStyle(Palette.text)
                if !pinsFooter { footer }
            }
            .padding(Metrics.screenMargin)
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
        }
        .safeAreaInset(edge: .bottom) {
            if pinsFooter {
                footer
                    .padding(.horizontal, Metrics.screenMargin)
                    .padding(.top, 10)
                    .frame(maxWidth: 640)
                    .frame(maxWidth: .infinity)
                    .background {
                        Rectangle().fill(Palette.bg.shadow(.drop(color: .black.opacity(0.08), radius: 8, y: -2))).ignoresSafeArea()
                    }
            }
        }
        .screenBackground()
        .sheet(isPresented: $showsPrivacy) { PrivacyPolicyView() }
    }
}

/// Today · Full access, no charge → Day 12 · We'll remind you → Oct 11 · Billed $39.99 unless you cancel.
struct TrialTimelineView: View {
    let billingDate: String
    let price: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TimelineStep(symbol: "lock.open.fill", title: "Today", detail: "Full access, no charge", isLast: false)
            TimelineStep(symbol: "bell.fill", title: "Day 12", detail: "We'll remind you", isLast: false)
            TimelineStepText(symbol: "creditcard.fill", title: billingDate,
                             detail: String(localized: "Billed \(price) unless you cancel"))
        }
        .cardStyle()
    }
}

private struct TimelineStep: View {
    let symbol: String
    let title: LocalizedStringResource
    let detail: LocalizedStringResource
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                Image(systemName: symbol)
                    .typeRole(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(Palette.onStrongFill)
                    .frame(width: 40, height: 40)
                    // The icon sits in a fixed 40 pt disc: it grows with the text only so far.
                    .dynamicTypeSize(...DynamicTypeSize.xxLarge)
                    .background(Palette.secondary, in: .circle)
                if !isLast { Rectangle().fill(Palette.secondary.opacity(0.4)).frame(width: 3, height: 22) }
            }
            .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 0) {
                Text(title).typeRole(.body).fontWeight(.bold)
                Text(detail).typeRole(.body)
            }
            .foregroundStyle(Palette.text)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct TimelineStepText: View {
    let symbol: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol)
                .typeRole(.body)
                    .fontWeight(.semibold)
                .foregroundStyle(Palette.onStrongFill)
                .frame(width: 40, height: 40)
                    // The icon sits in a fixed 40 pt disc: it grows with the text only so far.
                    .dynamicTypeSize(...DynamicTypeSize.xxLarge)
                .background(Palette.secondary, in: .circle)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 0) {
                Text(verbatim: title).typeRole(.body).fontWeight(.bold)
                Text(verbatim: detail).typeRole(.body)
            }
            .foregroundStyle(Palette.text)
        }
        .accessibilityElement(children: .combine)
    }
}

/// One plan: name, the billed price largest, a smaller monthly equivalent for yearly.
struct PlanOptionCard: View {
    let option: PlanOption
    let isSelected: Bool
    var showsTrialNote = false
    var renewingWarning = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .typeRole(.cardTitle)
                    .foregroundStyle(isSelected ? Palette.primary : Palette.textMuted)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.title).typeRole(.body).fontWeight(.semibold)
                    Text(verbatim: option.priceWithPeriod).typeRole(.cardTitle).fontWeight(.bold)
                    if let monthly = option.monthlyEquivalent {
                        Text(verbatim: monthly).typeRole(.caption).foregroundStyle(Palette.textMuted)
                    }
                    if showsTrialNote {
                        Text("Includes 14 days free").typeRole(.caption).foregroundStyle(Palette.text)
                    }
                    if option.kind == .lifetime {
                        Text("Yours to keep, no renewals").typeRole(.caption).foregroundStyle(Palette.text)
                    }
                    if renewingWarning {
                        Text("Your current plan keeps renewing until you cancel it.")
                            .typeRole(.caption).fontWeight(.semibold).foregroundStyle(Palette.text)
                    }
                }
                .foregroundStyle(Palette.text)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(Palette.surface, in: .rect(cornerRadius: Metrics.cardRadius))
            .overlay {
                RoundedRectangle(cornerRadius: Metrics.cardRadius)
                    .strokeBorder(isSelected ? Palette.primary : Palette.textMuted.opacity(0.25), lineWidth: isSelected ? 3 : 1)
            }
            .contentShape(.rect(cornerRadius: Metrics.cardRadius))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// What the plan includes.
struct IncludedList: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            line("All walking levels and weekly plans")
            line("All chair, balance and stretch sessions")
            line("4 more journeys, with more coming")
        }
    }

    private func line(_ text: LocalizedStringResource) -> some View {
        Label {
            Text(text).typeRole(.body)
        } icon: {
            Image(systemName: "checkmark").foregroundStyle(Palette.secondary)
        }
        .foregroundStyle(Palette.text)
    }
}
