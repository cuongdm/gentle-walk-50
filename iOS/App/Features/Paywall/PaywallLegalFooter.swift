import SwiftUI

/// Main button, the plain terms under it (two lines on an iPhone SE), then "Maybe later" and
/// Restore · Terms · Privacy on one row of 56 pt targets (3.1.1, 3.1.2; plan 08/10/2026 task 1.5).
/// The cancel note sits on the page, under the plans; on a short screen (iPhone SE) it comes here, under
/// the terms, where it was otherwise below the fold (review A, 09/10/2026).
struct PaywallLegalFooter: View {
    let disclosure: String
    var showsCancelNote = false
    let buttonTitle: LocalizedStringResource
    let onContinue: () -> Void
    let onMaybeLater: () -> Void
    let onRestore: () -> Void
    let onPrivacy: () -> Void

    private static let link = TextLinkButtonStyle(role: .caption, horizontalPadding: 4)

    var body: some View {
        VStack(spacing: 4) {
            Button(action: onContinue) { Text(buttonTitle) }.buttonStyle(.primaryAction)
            Text(verbatim: disclosure)
                .typeRole(.caption)
                .foregroundStyle(Palette.text)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            if showsCancelNote { CancelNote() }
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 0) { maybeLater; Spacer(minLength: 4); links }
                VStack(spacing: 0) { maybeLater; links }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var maybeLater: some View {
        Button("Maybe later", action: onMaybeLater).buttonStyle(Self.link)
    }

    /// One row where it fits; stacked at the largest text sizes (never wider than the screen).
    private var links: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 0) {
                restore
                Text(verbatim: "·").foregroundStyle(Palette.textMuted).accessibilityHidden(true)
                terms
                Text(verbatim: "·").foregroundStyle(Palette.textMuted).accessibilityHidden(true)
                privacy
            }
            .fixedSize()
            VStack(spacing: 0) { restore; terms; privacy }
        }
    }

    private var restore: some View { Button("Restore", action: onRestore).buttonStyle(Self.link) }
    private var terms: some View { Link("Terms", destination: LegalLinks.termsOfUse).buttonStyle(Self.link) }
    private var privacy: some View { Button("Privacy", action: onPrivacy).buttonStyle(Self.link) }
}

/// How to cancel, under the plans (the renewal and the 24 hours are said under the button).
struct CancelNote: View {
    var body: some View {
        Text("Cancel anytime in Settings. Deleting the app doesn't cancel.")
            .typeRole(.caption).foregroundStyle(Palette.textMuted)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
    }
}

/// Shown before Apple's purchase sheet: "Next, Apple will ask you to confirm. You won't be charged today."
/// It stays under Apple's sheet while the purchase runs; Continue then shows a spinner and Back waits.
struct BeforeAppleSheetView: View {
    let isTrial: Bool
    var isPurchasing = false
    let onContinue: () -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "checkmark.shield").font(.system(size: 48)).foregroundStyle(Palette.text).accessibilityHidden(true)
            Text("Next, Apple will ask you to confirm.")
                .typeRole(.screenTitle)
                .multilineTextAlignment(.center)
                .foregroundStyle(Palette.text)
            if isTrial {
                Text("You won't be charged today.").typeRole(.cardTitle).foregroundStyle(Palette.text)
            }
            Spacer()
            Button(action: onContinue) {
                if isPurchasing {
                    ProgressView().tint(Palette.onStrongFill).accessibilityLabel(Text("Continue"))
                } else {
                    Text("Continue")
                }
            }
            .buttonStyle(.primaryAction)
            // Not `.disabled`: a faded button reads as broken while Apple's sheet is coming up.
            .allowsHitTesting(!isPurchasing)
            Button("Back", action: onBack).buttonStyle(.textLink).disabled(isPurchasing)
        }
        .padding(Metrics.screenMargin)
        .screenBackground()
    }
}

/// The privacy policy in the app (the same text is published on the web in task 9.1).
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("\(AppBrand.name) keeps your health and workouts on this phone.").typeRole(.cardTitle)
                    Text("We don't have accounts, ads or tracking, and we never sell your data.")
                    Text("Your answers, workouts, pain reports and journey progress are stored only on this phone and are not backed up to iCloud by the app.")
                    Text("Your 2-week check results stay on this phone, too. They are compared only with your own earlier checks.")
                    Text("If you connect Apple Health, we read your step count to show it in Progress and to suggest a lighter session on busy days. We also save your workouts to Health. Health data never leaves your phone through us.")
                    Text("Outdoor walks use your location only while you walk, to measure distance and draw your route. The route stays on this phone and in Apple Health if you allow it.")
                    Text("Purchases are made through Apple. We never see your payment details.")
                    // RevenueCat (owner 09/10/2026): purchase history under a random ID, nothing health-related.
                    Text("To know which plan you have, the app sends your purchases, with basic details like your iOS version and country, to RevenueCat, the service that runs our subscriptions. It uses a random ID, not your name or Apple Account, and never anything about your health or workouts.")
                    Text("You can delete everything on this phone at any time in Me → Delete all my data.")
                }
                .typeRole(.body)
                .foregroundStyle(Palette.text)
                .padding(Metrics.screenMargin)
            }
            .screenBackground()
            .navigationTitle(Text("Privacy"))
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Close") { dismiss() } } }
        }
    }
}
