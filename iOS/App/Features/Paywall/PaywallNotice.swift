import SwiftUI

/// One calm line on the paywall after a purchase that did not unlock Pro (owner report 09/10/2026:
/// TestFlight showed Apple's "This item is not available." and the app added "check your connection").
/// The paywall stays open with Restore, Terms, Privacy and Maybe later; a cancelled purchase says nothing.
enum PaywallNotice: Equatable, Sendable {
    /// The store won't sell this plan in her App Store country, or not right now.
    case planUnavailable
    /// Ask to Buy, or a bank check.
    case pending
    /// The store took the purchase but the plan is not on yet.
    case notActive
    case couldNotConnect
    case couldNotFinish

    /// What the paywall says for a purchase failure.
    init(_ failure: PurchaseFailure) {
        switch failure.reason {
        case .planUnavailable: self = .planUnavailable
        case .network: self = .couldNotConnect
        case .other: self = .couldNotFinish
        }
    }

    /// No blame, no store jargon, and always a way on (another plan, later, or Restore).
    var message: LocalizedStringResource {
        switch self {
        case .planUnavailable:
            "This plan isn't available in your App Store country or right now. Try another plan or try again later."
        case .pending: "Waiting for approval. Your plan will start as soon as it's approved."
        case .notActive: "We're still confirming your purchase. If your plan hasn't started in a minute, tap Restore."
        case .couldNotConnect: "Couldn't reach the App Store. Please check your connection and try again."
        case .couldNotFinish: "The App Store couldn't finish the purchase. Please try again later."
        }
    }
}

/// The notice under the paywall title: an info mark (not at accessibility sizes) and the line on card
/// paper, read out by VoiceOver when it appears.
struct PaywallNoticeView: View {
    let notice: PaywallNotice
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            // At accessibility sizes the mark took a column of its own and left two words a line.
            if !typeSize.isAccessibilitySize {
                Image(systemName: "info.circle")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Palette.text)
                    .accessibilityHidden(true)
            }
            Text(notice.message)
                .typeRole(.body)
                .foregroundStyle(Palette.text)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background { CardPaper() }
        .accessibilityElement(children: .combine)
        .task(id: notice) {
            AccessibilityNotification.Announcement(String(localized: notice.message)).post()
        }
    }
}
