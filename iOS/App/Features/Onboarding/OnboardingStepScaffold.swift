import SwiftUI
import GentleWalkCore

/// One frame for every onboarding question (plan 08/10/2026 task 2.4): Back with a word, the garden
/// and "Step n of 7" on one row; a title of at most eight words; the coach's slot, a fixed two lines
/// that hold a hint before she answers and the coach's face and reply after, so nothing below it
/// moves; the answers; then Continue (and a footer such as the doctor note) pinned at the bottom. At
/// accessibility text sizes nothing is pinned: the page scrolls and the buttons follow the answers.
struct OnboardingStepScaffold<Content: View, Footer: View>: View {
    let title: LocalizedStringResource
    let coach: CoachLine?
    var continueTitle: LocalizedStringResource = "Continue"
    /// "Pick one to continue": Continue says why it can't go on yet.
    var blockedReason: String? = nil
    let onContinue: () -> Void
    /// On a short screen (iPhone SE) the footer above Continue moves into the page, under the answers, so
    /// the last answer is not hidden behind it (Anything else: "None of these" under the doctor note).
    var footerScrollsWhenShort = false
    @ViewBuilder let content: () -> Content
    /// Under Continue (Skip) or above it (the doctor note), inside the pinned area.
    @ViewBuilder var aboveContinue: () -> Footer
    var belowContinue: AnyView? = nil

    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var isShort = false
    private var pins: Bool { !typeSize.isAccessibilitySize }
    private var footerInPage: Bool { footerScrollsWhenShort && isShort }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .typeRole(.screenTitle)
                    .foregroundStyle(Palette.text)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                CoachSlot(line: coach)
                content()
                    .padding(.top, 2)
                if pins && footerInPage { aboveContinue().padding(.top, 6) }
                if !pins { actions }
            }
            .padding(.horizontal, Metrics.screenMargin)
            .padding(.bottom, 16)
            .readableColumn()
        }
        .scrollBounceBehavior(.basedOnSize)
        .pinnedActions(pins) { actions }
        .onShortHeightChange { isShort = $0 }
    }

    @ViewBuilder private var actions: some View {
        if !(pins && footerInPage) { aboveContinue() }
        ContinueButton(title: continueTitle, blockedReason: blockedReason, action: onContinue)
        if let belowContinue { belowContinue }
    }
}

extension OnboardingStepScaffold where Footer == EmptyView {
    init(title: LocalizedStringResource, coach: CoachLine?, continueTitle: LocalizedStringResource = "Continue",
         blockedReason: String? = nil, onContinue: @escaping () -> Void, belowContinue: AnyView? = nil,
         @ViewBuilder content: @escaping () -> Content) {
        self.init(title: title, coach: coach, continueTitle: continueTitle, blockedReason: blockedReason,
                  onContinue: onContinue, content: content, aboveContinue: { EmptyView() }, belowContinue: belowContinue)
    }
}

/// The coach's fixed slot: two lines of body text tall at every moment, so an answer never pushes the
/// list. Before she answers, a quiet hint; after, the coach's face and a short reply, faded in (a
/// fade only, under 0.4 s). VoiceOver hears the reply once, as an announcement.
struct CoachSlot: View {
    let line: CoachLine?

    @ScaledMetric(relativeTo: .body) private var height: CGFloat = 54
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOver

    var body: some View {
        ZStack(alignment: .leading) {
            if let line {
                Group {
                    if line.isReply {
                        HStack(alignment: .center, spacing: 10) {
                            // At accessibility sizes the words take the whole width.
                            if !typeSize.isAccessibilitySize { CoachFace(size: 40) }
                            Text(line.text)
                                .typeRole(.body)
                                .foregroundStyle(Palette.text)
                                .minimumScaleFactor(0.8)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Palette.surface.opacity(0.85),
                                            in: UnevenRoundedRectangle(topLeadingRadius: 4, bottomLeadingRadius: 14,
                                                                       bottomTrailingRadius: 14, topTrailingRadius: 14))
                        }
                    } else {
                        Text(line.text)
                            .typeRole(.body)
                            .foregroundStyle(Palette.textMuted)
                            .minimumScaleFactor(0.8)
                    }
                }
                .id(String(localized: line.text))
                .transition(.opacity)
            }
        }
        // Two lines at the default size; at accessibility sizes the words take what they need.
        .frame(maxWidth: .infinity, minHeight: height, maxHeight: typeSize.isAccessibilitySize ? nil : height, alignment: .leading)
        .animation(.easeInOut(duration: 0.3), value: line)
        .accessibilityElement(children: .combine)
        .onChange(of: line) { _, new in
            guard voiceOver, let new, new.isReply else { return }
            AccessibilityNotification.Announcement(String(localized: new.text)).post()
        }
    }
}

/// Back with a word, the garden, and "Step 3 of 7" on one row (the garden takes the room between);
/// at accessibility sizes the garden goes under the row.
struct OnboardingHeader: View {
    let label: String?
    let gardenStep: Int
    let onBack: () -> Void

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        Group {
            if typeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 4) {
                    HStack { back; Spacer(); stepLabel }
                    GardenProgress(step: gardenStep)
                }
            } else {
                HStack(spacing: 6) {
                    back.fixedSize()
                    GardenProgress(step: gardenStep).frame(maxWidth: 300).frame(maxWidth: .infinity)
                    stepLabel.fixedSize()
                }
            }
        }
        .padding(.horizontal, Metrics.screenMargin)
        .readableColumn()
    }

    private var back: some View {
        Button(action: onBack) {
            Label("Back", systemImage: "chevron.left")
        }
        .buttonStyle(.smallTextLink)
    }

    @ViewBuilder private var stepLabel: some View {
        if let label {
            Text(verbatim: label).typeRole(.caption).foregroundStyle(Palette.textMuted)
        }
    }
}

/// Continue. When the screen still needs an answer it says why instead of fading out (control
/// states, owner 08/10/2026): a dashed outline with "Pick one to continue", not tappable.
struct ContinueButton: View {
    var title: LocalizedStringResource = "Continue"
    var blockedReason: String?
    let action: () -> Void

    var body: some View {
        if let blockedReason {
            Button {} label: { Text(verbatim: blockedReason) }
                .buttonStyle(NotYetButtonStyle())
                .disabled(true)
        } else {
            Button(action: action) { Text(title) }
                .buttonStyle(.primaryAction)
        }
    }
}

/// "Not yet": a main-button shape with a dashed outline and the reason as its label.
struct NotYetButtonStyle: ButtonStyle {
    private static let shape = RoundedRectangle(cornerRadius: Metrics.buttonRadius, style: .continuous)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .typeRole(.button)
            .multilineTextAlignment(.center)
            .foregroundStyle(Palette.text)
            .padding(.horizontal, Metrics.screenMargin)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: Metrics.buttonHeight)
            .background(Palette.textMuted.opacity(0.08), in: Self.shape)
            .overlay { Self.shape.strokeBorder(Palette.textMuted.opacity(0.6), style: StrokeStyle(lineWidth: 2, dash: [6, 5])) }
    }
}

/// "Check with your doctor first" (1.4.1): pinned with Continue on Anything else (D4). 06/10/2026: a fall
/// or fainting in the past year added (PAR-Q+ question 3, World Falls Guidelines 2022). A reminder only:
/// nothing is asked or stored.
struct DoctorNote: View {
    var body: some View {
        Label("If you have a heart condition, recent surgery, a fall or fainting in the past year, or you've been told to limit exercise, check with your doctor first.",
              systemImage: "stethoscope")
            .typeRole(.caption)
            .foregroundStyle(Palette.text)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
