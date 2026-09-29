import SwiftUI

/// Main button, the disclosure under it, "Maybe later", and Restore · Terms · Privacy (3.1.1, 3.1.2).
struct PaywallLegalFooter: View {
    let disclosure: String
    let buttonTitle: LocalizedStringResource
    let onContinue: () -> Void
    let onMaybeLater: () -> Void
    let onRestore: () -> Void
    let onPrivacy: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Button(action: onContinue) { Text(buttonTitle) }.buttonStyle(.primaryAction)
            Text(verbatim: disclosure)
                .typeRole(.caption)
                .foregroundStyle(Palette.text)
                .multilineTextAlignment(.center)
            Button("Maybe later", action: onMaybeLater).buttonStyle(.textLink)
            HStack(spacing: 8) {
                Button("Restore", action: onRestore).buttonStyle(.smallTextLink)
                Text(verbatim: "·").foregroundStyle(Palette.textMuted).accessibilityHidden(true)
                Link("Terms", destination: LegalLinks.termsOfUse).buttonStyle(.smallTextLink)
                Text(verbatim: "·").foregroundStyle(Palette.textMuted).accessibilityHidden(true)
                Button("Privacy", action: onPrivacy).buttonStyle(.smallTextLink)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

/// Shown before Apple's purchase sheet: "Next, Apple will ask you to confirm. You won't be charged today."
struct BeforeAppleSheetView: View {
    let isTrial: Bool
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
            Button("Continue", action: onContinue).buttonStyle(.primaryAction)
            Button("Back", action: onBack).buttonStyle(.textLink)
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
                    Text("Gentle Walk keeps everything on this phone.").typeRole(.cardTitle)
                    Text("We don't have accounts, servers, ads or tracking. We don't collect or sell your data.")
                    Text("Your answers, workouts, pain reports and journey progress are stored only on this phone and are not backed up to iCloud by the app.")
                    Text("If you connect Apple Health, we read your step count to show it in Progress and save your workouts to Health. Health data never leaves your phone through us.")
                    Text("Outdoor walks use your location only while you walk, to measure distance and draw your route. The route stays on this phone and in Apple Health if you allow it.")
                    Text("Purchases are handled by Apple. We never see your payment details.")
                    Text("You can delete everything at any time in Me → Delete all my data.")
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
