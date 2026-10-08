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
            // Title, three lines, the trial dates and all three plans fit above the pinned footer on an
            // iPhone SE (plan 08/10/2026 task 1.5); the free plan and the cancel note follow.
            VStack(alignment: .leading, spacing: 8) {
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
                .padding(.top, model.options.contains(where: \.isLowestMonthly) ? 8 : 0)
                FreePlanNote()
                CancelNote()
                if !pinsFooter { footer }
            }
            .padding(.horizontal, Metrics.screenMargin)
            .padding(.top, 12)
            .padding(.bottom, Metrics.screenMargin)
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

/// Today · Full access, no charge → Oct 20 · We'll remind you → Oct 22 · Billed $39.99. One line per
/// step on an iPhone SE (plan 08/10/2026 task 1.5); "unless you cancel" is in the terms under the
/// button. The reminder is a calendar date like the charge (review M11, 02/10/2026).
struct TrialTimelineView: View {
    let reminderDate: String
    let billingDate: String
    let price: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // The trial reads top to bottom, one step after another (redesign 03/10/2026).
            TimelineStep(symbol: "lock.open.fill", title: String(localized: "Today"), detail: String(localized: "Full access, no charge"))
                .reveal(delay: 0.2)
            TimelineStep(symbol: "bell.fill", title: reminderDate, detail: String(localized: "We'll remind you"))
                .reveal(delay: 0.55)
            TimelineStep(symbol: "creditcard.fill", title: billingDate, detail: String(localized: "Billed \(price)"))
                .reveal(delay: 0.9)
        }
        .cardStyle(padding: 10)
    }
}

private struct TimelineStep: View {
    let symbol: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Palette.onStrongFill)
                .frame(width: 28, height: 28)
                .background(Palette.secondary, in: .circle)
                .alignmentGuide(.firstTextBaseline) { $0[VerticalAlignment.center] + 6 }
                .accessibilityHidden(true)
            // "Today  Full access, no charge" on one line where it fits.
            Text("\(Text(verbatim: title).bold())  \(Text(verbatim: detail))")
                .typeRole(.body)
                .foregroundStyle(Palette.text)
        }
        .frame(minHeight: 26)
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
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        Button(action: action) {
            // Price beside the name; under it at the largest text sizes, so the row never runs off
            // the screen.
            let layout = typeSize.isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
                : AnyLayout(HStackLayout(alignment: .center, spacing: 12))
            layout {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .typeRole(.cardTitle)
                    .foregroundStyle(isSelected ? Palette.primary : Palette.textMuted)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 0) {
                    Text(option.title).typeRole(.body).fontWeight(.semibold)
                    if showsTrialNote {
                        Text("14 days free").typeRole(.caption).foregroundStyle(Palette.text)
                    }
                    if option.kind == .lifetime {
                        Text("No renewals").typeRole(.caption).foregroundStyle(Palette.text)
                    }
                    if renewingWarning {
                        Text("Your current plan keeps renewing until you cancel it.")
                            .typeRole(.caption).fontWeight(.semibold).foregroundStyle(Palette.text)
                    }
                }
                .foregroundStyle(Palette.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: typeSize.isAccessibilitySize ? .leading : .trailing, spacing: 0) {
                    Text(verbatim: option.priceWithPeriod).typeRole(.cardTitle).fontWeight(.bold)
                    if let monthly = option.monthlyEquivalent {
                        Text(verbatim: monthly).typeRole(.caption).foregroundStyle(Palette.textMuted)
                    }
                }
                .foregroundStyle(Palette.text)
                .fixedSize(horizontal: !typeSize.isAccessibilitySize, vertical: true)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .frame(minHeight: 52)
            .background(Palette.surface, in: .rect(cornerRadius: Metrics.cardRadius))
            .overlay {
                RoundedRectangle(cornerRadius: Metrics.cardRadius)
                    .strokeBorder(isSelected ? Palette.primary : Palette.textMuted.opacity(0.25), lineWidth: isSelected ? 3 : 1)
            }
            // "Lowest monthly cost" as a tab on the card's top edge: no extra row (task 1.5). Only when
            // StoreKit prices prove it (`isLowestMonthly`).
            .overlay(alignment: .topTrailing) {
                if option.isLowestMonthly {
                    Text("Lowest monthly cost")
                        .typeRole(.caption).fontWeight(.semibold)
                        .foregroundStyle(Palette.onStrongFill)
                        .padding(.horizontal, 10)
                        .background(Palette.secondary, in: .capsule)
                        .offset(x: -14, y: -11)
                }
            }
            .contentShape(.rect(cornerRadius: Metrics.cardRadius))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// What the plan includes: three one-line benefits at caption size (task 1.5).
struct IncludedList: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            line("All walking levels and weekly plans")
            line("Chair, balance and stretch sessions")
            line("4 more journeys, with more coming")
        }
    }

    private func line(_ text: LocalizedStringResource) -> some View {
        Label {
            Text(text).typeRole(.caption)
        } icon: {
            Image(systemName: "checkmark").fontWeight(.semibold).foregroundStyle(Palette.secondary)
        }
        .foregroundStyle(Palette.text)
    }
}
