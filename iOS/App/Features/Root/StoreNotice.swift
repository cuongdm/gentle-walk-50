import SwiftUI
import Foundation

/// What Restore did, told in plain words (review I10: silence reads as "broken"). A purchase answers on
/// the paywall itself (`PaywallNotice`, 09/10/2026), not in an alert over Apple's own.
enum StoreNotice: Equatable, Sendable {
    case restored, nothingToRestore, failed
    /// The session's audio could not be put together.
    case sessionFailed
    /// Me → Delete all my data: done (it dropped her on Welcome without a word; review 02/10/2026).
    case dataDeleted

    var title: LocalizedStringResource {
        switch self {
        case .restored: "Purchase restored"
        case .nothingToRestore: "No purchases found"
        case .failed: "Couldn't reach the App Store"
        case .sessionFailed: "Couldn't start the session"
        case .dataDeleted: "Your data is deleted"
        }
    }

    var message: LocalizedStringResource {
        switch self {
        case .restored: "Your plan is back on this iPhone."
        case .nothingToRestore: "We couldn't find a purchase for this Apple Account."
        case .failed: "Please check your connection and try again."
        case .sessionFailed: "Please try again. If it keeps happening, restart the app."
        case .dataDeleted: "Everything is deleted from this phone. You can start again whenever you like."
        }
    }
}


/// The Restore answer (and the other notices) as an alert, on whichever screen is on top (root or cover).
struct StoreNoticeAlert: ViewModifier {
    @Bindable var app: AppModel

    func body(content: Content) -> some View {
        content.alert(app.storeNotice.map { Text($0.title) } ?? Text(verbatim: ""), isPresented: $app.showsStoreNotice,
                      presenting: app.storeNotice) { _ in
            Button("OK") {}
        } message: { notice in
            Text(notice.message)
        }
    }
}

extension View {
    func storeNoticeAlert(_ app: AppModel) -> some View { modifier(StoreNoticeAlert(app: app)) }
}
