import StoreKit
import SwiftUI

/// S21 Cancel guide: three plain steps and a button to Apple's subscription page. No "Are you
/// sure?" screen. After buying one payment while a plan still renews, the title asks to cancel it.
struct CancelGuideView: View {
    /// "Oct 11": access lasts until then.
    let accessUntil: String?
    var isAfterLifetimePurchase = false
    let onBack: () -> Void
    @State private var showsManage = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ScreenHeader(title: isAfterLifetimePurchase ? "One last step: cancel your old plan" : "Canceling takes a minute")
                GuideStep(number: 1, text: "Tap the button below", symbol: "hand.tap")
                GuideStep(number: 2, text: "Choose this subscription", symbol: "list.bullet")
                GuideStep(number: 3, text: "Tap Cancel Subscription", symbol: "xmark.circle")
                if let accessUntil {
                    Text("You keep full access until \(accessUntil).").typeRole(.body).foregroundStyle(Palette.text)
                }
                Button("Open Apple subscriptions") { showsManage = true }.buttonStyle(.primaryAction)
                Button("Back", action: onBack).buttonStyle(.textLink).frame(maxWidth: .infinity)
            }
            .padding(Metrics.screenMargin)
        }
        .screenBackground()
        .manageSubscriptionsSheet(isPresented: $showsManage)
    }
}

private struct GuideStep: View {
    let number: Int
    let text: LocalizedStringResource
    let symbol: String

    var body: some View {
        HStack(spacing: 14) {
            Text(verbatim: "\(number)")
                .typeRole(.cardTitle)
                .foregroundStyle(Palette.onStrongFill)
                .frame(width: 48, height: 48)
                .background(Palette.secondary, in: .circle)
            VStack(alignment: .leading, spacing: 8) {
                Text(text).typeRole(.body).fontWeight(.semibold).foregroundStyle(Palette.text)
                IllustrationPlaceholder(symbol: symbol, tint: Palette.sky, height: 64)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
