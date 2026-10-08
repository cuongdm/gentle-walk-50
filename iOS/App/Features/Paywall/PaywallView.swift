import SwiftUI

/// S08 Paywall, the simple version (Claude Design "Paywall" and "Paywall, other plans", owner 08/10/2026:
/// the old screen was crowded). Her goal said back as the title, the trial as three dated steps on a
/// dotted line (no frame), Yearly alone and chosen, and "See other plans" opening Monthly and One payment
/// in place. Money is shown plainly: the billed price is the largest price, the terms sit under the
/// button, and Maybe later · Restore · Terms · Privacy are always on screen. No countdowns, no
/// struck-through prices, no benefit checklist (Your plan, just before, says what she gets).
struct PaywallView: View {
    @Bindable var model: PaywallModel
    let onPurchase: (PlanOption) -> Void
    let onRestore: () -> Void
    let onMaybeLater: () -> Void
    @State private var showsPrivacy = false
    /// An iPhone SE: the cancel note moves into the pinned footer (`onShortHeightChange`).
    @State private var isShort = false
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// At normal text sizes the button, terms and links stay pinned at the bottom, so they are
    /// visible without scrolling even on the smallest iPhone (3.1.1, 3.1.2). At accessibility
    /// sizes they scroll with the page, so they never cover it.
    private var pinsFooter: Bool { !typeSize.isAccessibilitySize }

    private var footer: some View {
        PaywallLegalFooter(disclosure: model.disclosure, showsCancelNote: pinsFooter && isShort,
                           buttonTitle: model.buttonTitle,
                           onContinue: { if let selected = model.selected { onPurchase(selected) } },
                           onMaybeLater: onMaybeLater, onRestore: onRestore, onPrivacy: { showsPrivacy = true })
    }

    /// The end of the plan list: "See other plans" scrolls here once the list has opened, so the last plan
    /// and "Fewer plans" sit above the pinned footer on an iPhone SE (review A, 09/10/2026).
    private static let plansEnd = "plans-end"

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    PaywallHeader(title: model.title, showsAllPlans: model.showsAllPlans, onClose: onMaybeLater)
                    if model.showsAllPlans {
                        Text("Every plan unlocks the same things.").typeRole(.body).foregroundStyle(Palette.text)
                            .padding(.top, -8)
                    } else if model.showsTrial {
                        TrialTimelineView(reminderDate: model.reminderDateText, billingDate: model.billingDateText)
                    }
                    // Every card the same way: price beside the name when all of them fit so, otherwise under the
                    // name on every card, so the prices line up down the list (review A, 09/10/2026).
                    ViewThatFits(in: .horizontal) {
                        planCards(stacksPrice: false)
                        planCards(stacksPrice: true)
                    }
                    OtherPlansToggle(showsAll: model.showsAllPlans) { model.showsAllPlans.toggle() }
                    if !(pinsFooter && isShort) { CancelNote() }
                    // Below the last plan and its toggle, with a little air above the pinned footer.
                    Color.clear.frame(height: 8).id(Self.plansEnd)
                    if !pinsFooter { footer }
                }
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: model.showsAllPlans)
                .padding(.horizontal, Metrics.screenMargin)
                .padding(.top, 4)
                .padding(.bottom, Metrics.screenMargin)
                .readableColumn()
            }
            .scrollBounceBehavior(.basedOnSize)
            .safeAreaInset(edge: .bottom) {
                if pinsFooter {
                    footer
                        .padding(.horizontal, Metrics.screenMargin)
                        .padding(.top, 10)
                        .readableColumn()
                        .background {
                            Rectangle().fill(Palette.bg.shadow(.drop(color: .black.opacity(0.08), radius: 8, y: -2))).ignoresSafeArea()
                        }
                }
            }
            .onChange(of: model.showsAllPlans) { _, showsAll in
                guard showsAll else { return }
                // After the cards' 0.25 s insert animation: scrolling at once used the old, shorter list and
                // left the third plan half under the footer in Vietnamese on an iPhone SE (Mac 09/10/2026).
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(reduceMotion ? 50 : 320))
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                        proxy.scrollTo(Self.plansEnd, anchor: .bottom)
                    }
                }
            }
        }
        .onShortHeightChange { isShort = $0 }
        .screenBackground()
        .sheet(isPresented: $showsPrivacy) { PrivacyPolicyView() }
    }

    private func planCards(stacksPrice: Bool) -> some View {
        VStack(spacing: 10) {
            ForEach(model.visibleOptions) { option in
                PlanOptionCard(option: option, isSelected: model.selectedID == option.id,
                               note: model.note(for: option),
                               renewingWarning: option.kind == .lifetime && model.showsRenewingWarning,
                               stacksPrice: stacksPrice) {
                    model.selectedID = option.id
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

/// "GOOD FOOTING PRO" with the coach, the title, and a Close button that is the same as Maybe later.
private struct PaywallHeader: View {
    let title: LocalizedStringResource
    let showsAllPlans: Bool
    let onClose: () -> Void
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 10) {
                if !showsAllPlans && !typeSize.isAccessibilitySize {
                    CoachFace(size: 36)
                }
                if !showsAllPlans {
                    Text(verbatim: "\(AppBrand.name) Pro".uppercased())
                        .typeRole(.caption).fontWeight(.semibold).tracking(1.2)
                        .foregroundStyle(Palette.accent)
                        .accessibilityLabel(Text(verbatim: "\(AppBrand.name) Pro"))
                }
                Spacer(minLength: 0)
            }
            // Room for Close, so a two-line label at the largest sizes never runs under it (review A).
            .padding(.trailing, Metrics.minTouchTarget - 8)
            .frame(minHeight: 40)
            // Close sits over the row's end: a 56 pt target without making the row taller.
            .overlay(alignment: .trailing) {
                Button(action: onClose) {
                    Image(systemName: "xmark").font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Palette.text)
                        .frame(width: 40, height: 40)
                        .background(Palette.surface, in: .circle)
                        .overlay { Circle().strokeBorder(Palette.textMuted.opacity(0.3), lineWidth: 1) }
                        .frame(width: Metrics.minTouchTarget, height: Metrics.minTouchTarget)
                        .contentShape(.circle)
                }
                .buttonStyle(.plain)
                .padding(.trailing, -8)
                .accessibilityLabel(Text("Close"))
            }
            Text(title)
                .typeRole(.screenTitle)
                .foregroundStyle(Palette.text)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
        }
    }
}

/// Today · Full access, no charge → Oct 20 · We remind you → Oct 22 · First charge, unless you cancel.
/// Three dots on a dotted line, no frame (Claude Design). The reminder is a calendar date like the
/// charge (review M11, 02/10/2026).
struct TrialTimelineView: View {
    let reminderDate: String
    let billingDate: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TimelineStep(dot: .filled(Palette.secondary), title: String(localized: "Today"),
                         detail: String(localized: "Full access, no charge"), continues: true)
                .reveal(delay: 0.15)
            TimelineStep(dot: .filled(Palette.sun), title: reminderDate, detail: String(localized: "We remind you"), continues: true)
                .reveal(delay: 0.4)
            TimelineStep(dot: .ring(Palette.accent), title: billingDate,
                         detail: String(localized: "First charge, unless you cancel"), continues: false)
                .reveal(delay: 0.65)
        }
    }
}

private struct TimelineStep: View {
    enum Dot { case filled(Color), ring(Color) }

    let dot: Dot
    let title: String
    let detail: String
    let continues: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 2) {
                Group {
                    switch dot {
                    case .filled(let color): Circle().fill(color)
                    case .ring(let color): Circle().strokeBorder(color, lineWidth: 2.5)
                    }
                }
                .frame(width: 16, height: 16)
                .padding(.top, 5)
                if continues {
                    DottedLine().frame(width: 2).frame(maxHeight: .infinity)
                }
            }
            .frame(width: 16)
            .accessibilityHidden(true)
            Text("\(Text(verbatim: title).bold()) · \(Text(verbatim: detail))")
                .typeRole(.body)
                .foregroundStyle(Palette.text)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, continues ? 4 : 0)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct DottedLine: View {
    var body: some View {
        GeometryReader { proxy in
            Path { path in
                path.move(to: CGPoint(x: proxy.size.width / 2, y: 0))
                path.addLine(to: CGPoint(x: proxy.size.width / 2, y: proxy.size.height))
            }
            .stroke(Palette.textMuted.opacity(0.45), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [0.5, 5]))
        }
    }
}

/// One plan: a radio (filled check when chosen), the name and its note, the billed price as the
/// largest price. Chosen: ochre fill, 3 pt border, bold, check (never colour alone).
struct PlanOptionCard: View {
    let option: PlanOption
    let isSelected: Bool
    var note: String?
    var renewingWarning = false
    /// The price under the name instead of beside it; the list picks one way for every card.
    var stacksPrice = false
    let action: () -> Void
    @Environment(\.colorScheme) private var scheme

    private static let shape = RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)

    /// Held at xxxLarge: at the largest sizes a 70 pt check left "One paymen / t" breaking mid-word (review A).
    private var radio: some View {
        Group {
            if isSelected {
                ChosenCheck()
            } else {
                Circle().strokeBorder(Palette.textMuted.opacity(0.6), lineWidth: 2)
                    .frame(width: 28, height: 28).accessibilityHidden(true)
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(option.title).typeRole(.body).fontWeight(isSelected ? .bold : .regular)
                .fixedSize(horizontal: false, vertical: true)
            if let note {
                // Wraps, never "$4.17 a…" at the largest sizes (review A, 09/10/2026).
                Text(verbatim: note).typeRole(.caption)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if renewingWarning {
                Text("Your current plan keeps renewing until you cancel it.")
                    .typeRole(.caption).fontWeight(.semibold)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .foregroundStyle(Palette.text)
    }

    private var price: some View {
        Text(verbatim: option.priceWithPeriod)
            .typeRole(.cardTitle).fontWeight(.bold)
            .foregroundStyle(Palette.text)
    }

    var body: some View {
        Button(action: action) {
            // Price beside the name where every name keeps one line; under it otherwise (long names in
            // Vietnamese, accessibility sizes), so the row never squeezes or runs off the screen.
            Group {
                if !stacksPrice {
                    HStack(alignment: .center, spacing: 12) {
                        radio
                        details.fixedSize()
                        Spacer(minLength: 8)
                        price.fixedSize()
                    }
                } else {
                    HStack(alignment: .top, spacing: 12) {
                        radio
                        VStack(alignment: .leading, spacing: 2) {
                            details
                            price
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(minHeight: Metrics.rowHeight)
            .background {
                if isSelected { ChosenFill(cornerRadius: Metrics.cardRadius) } else { CardPaper() }
            }
            .overlay {
                Self.shape.strokeBorder(isSelected ? ChoiceInk.chosen(scheme) : Palette.textMuted.opacity(0.25),
                                        lineWidth: isSelected ? 3 : 1)
            }
            .contentShape(Self.shape)
        }
        .buttonStyle(PressableCardStyle())
        .sensoryFeedback(.selection, trigger: isSelected)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// "See other plans ⌄" / "Fewer plans ⌃": an underlined link, never plain grey text.
private struct OtherPlansToggle: View {
    let showsAll: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(showsAll ? "Fewer plans" : "See other plans")
                Image(systemName: showsAll ? "chevron.up" : "chevron.down").font(.caption.weight(.bold)).accessibilityHidden(true)
            }
        }
        .buttonStyle(TextLinkButtonStyle(role: .body))
        .frame(maxWidth: .infinity)
    }
}
