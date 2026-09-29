import SwiftUI
import Foundation

/// What a purchase or Restore did, told in plain words (review I10: silence reads as "broken").
enum StoreNotice: Equatable, Sendable {
    case restored, nothingToRestore, failed, pending
    /// The session's audio could not be put together.
    case sessionFailed

    var title: LocalizedStringResource {
        switch self {
        case .restored: "Purchase restored"
        case .nothingToRestore: "No purchases found"
        case .failed: "Couldn't reach the App Store"
        case .pending: "Waiting for approval"
        case .sessionFailed: "Couldn't start the session"
        }
    }

    var message: LocalizedStringResource {
        switch self {
        case .restored: "Your plan is back on this iPhone."
        case .nothingToRestore: "We couldn't find a purchase for this Apple Account."
        case .failed: "Please check your connection and try again."
        case .pending: "Your purchase will start as soon as it's approved."
        case .sessionFailed: "Please try again. If it keeps happening, restart the app."
        }
    }
}


/// The purchase / Restore answer as an alert, on whichever screen is on top (root or cover).
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
