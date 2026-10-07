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
            VStack(alignment: .leading, spacing: 12) {
                ScreenHeader(title: model.title)
                // What Pro adds comes first, then the dates and prices (clarity review D4).
                IncludedList()
                if model.showsTrial, let yearly = model.yearly {
                    TrialTimelineView(reminderDate: model.reminderDateText, billingDate: model.billingDateText, price: yearly.price)
                }
                VStack(spacing: 8) {
                    ForEach(model.options) { option in
                        PlanOptionCard(option: option, isSelected: model.selectedID == option.id,
                                       showsTrialNote: option.kind == .yearly && model.isEligibleForTrial,
                                       renewingWarning: option.kind == .lifetime && model.showsRenewingWarning) {
                            model.selectedID = option.id
                        }
                    }
                }
                Text("Cancel anytime in Settings. Deleting the app doesn't cancel.")
                    .typeRole(.caption)
                    .foregroundStyle(Palette.text)
                FreePlanNote()
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

/// Today · Full access, no charge → Oct 9 · We'll remind you → Oct 11 · Billed $39.99 unless you
/// cancel. The reminder is a calendar date like the charge (review M11, 02/10/2026).
struct TrialTimelineView: View {
    let reminderDate: String
    let billingDate: String
    let price: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // The trial reads top to bottom, one step after another (redesign 03/10/2026).
            TimelineStep(symbol: "lock.open.fill", title: Text("Today"), detail: Text("Full access, no charge"), isLast: false)
                .reveal(delay: 0.2)
            TimelineStep(symbol: "bell.fill", title: Text(verbatim: reminderDate), detail: Text("We'll remind you"), isLast: false)
                .reveal(delay: 0.55)
            TimelineStepText(symbol: "creditcard.fill", title: billingDate,
                             detail: String(localized: "Billed \(price) unless you cancel"))
                .reveal(delay: 0.9)
        }
        .cardStyle(padding: 12)
    }
}

private struct TimelineStep: View {
    let symbol: String
    let title: Text
    let detail: Text
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                Image(systemName: symbol)
                    .typeRole(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(Palette.onStrongFill)
                    .frame(width: 32, height: 32)
                    // The icon sits in a fixed 32 pt disc: it grows with the text only so far.
                    .dynamicTypeSize(...DynamicTypeSize.xxLarge)
                    .background(Palette.secondary, in: .circle)
                if !isLast { Rectangle().fill(Palette.secondary.opacity(0.4)).frame(width: 3, height: 6) }
            }
            .accessibilityHidden(true)
            // "Today  Full access, no charge" on one line where it fits.
            Text("\(title.bold())  \(detail)")
                .typeRole(.body)
                .foregroundStyle(Palette.text)
                .frame(minHeight: 32)
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
                .frame(width: 32, height: 32)
                    // The icon sits in a fixed 32 pt disc: it grows with the text only so far.
                    .dynamicTypeSize(...DynamicTypeSize.xxLarge)
                .background(Palette.secondary, in: .circle)
                .accessibilityHidden(true)
            Text("\(Text(verbatim: title).bold())  \(Text(verbatim: detail))")
                .typeRole(.body)
                .foregroundStyle(Palette.text)
                .frame(minHeight: 32)
        }
        .accessibilityElement(children: .combine)
    }
}

/// One plan on one row (owner 01/10: three tall cards were hidden under the pinned button): the
/// name and its notes on the left, the billed price on the right as the largest price, a smaller
/// monthly equivalent under the yearly price.
struct PlanOptionCard: View {
    let option: PlanOption
    let isSelected: Bool
    var showsTrialNote = false
    var renewingWarning = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .typeRole(.cardTitle)
                    .foregroundStyle(isSelected ? Palette.primary : Palette.textMuted)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(option.title).typeRole(.body).fontWeight(.semibold)
                    if option.isLowestMonthly {
                        Text("Lowest monthly cost")
                            .typeRole(.caption).fontWeight(.semibold)
                            .foregroundStyle(Palette.text)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Palette.secondary.opacity(0.15), in: .capsule)
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
                VStack(alignment: .trailing, spacing: 2) {
                    Text(verbatim: option.priceWithPeriod).typeRole(.cardTitle).fontWeight(.bold)
                        .lineLimit(1).minimumScaleFactor(0.8)
                    if let monthly = option.monthlyEquivalent {
                        Text(verbatim: monthly).typeRole(.caption).foregroundStyle(Palette.textMuted)
                    }
                }
                .foregroundStyle(Palette.text)
                .fixedSize()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
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
        VStack(alignment: .leading, spacing: 4) {
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
