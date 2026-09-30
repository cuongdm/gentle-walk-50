import SwiftUI

/// Screen title (30 pt bold, at most two lines) and an optional subtitle.
struct ScreenHeader: View {
    let title: LocalizedStringResource
    var subtitle: LocalizedStringResource? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .typeRole(.screenTitle)
                .foregroundStyle(Palette.text)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            if let subtitle {
                Text(subtitle).typeRole(.body).foregroundStyle(Palette.text)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Screen title built from a string that is already localized (e.g. with the user's name).
struct ScreenHeaderText: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(verbatim: title)
                .typeRole(.screenTitle)
                .foregroundStyle(Palette.text)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            if let subtitle {
                Text(verbatim: subtitle).typeRole(.body).foregroundStyle(Palette.text)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A sheet's title with Close on the same line, instead of Close alone on a row above (review U9).
struct ClosableHeader: View {
    let title: String
    var subtitle: String? = nil
    let onClose: () -> Void

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            ScreenHeaderText(title: title, subtitle: subtitle)
            Button("Close", action: onClose).buttonStyle(.smallTextLink).fixedSize()
        }
    }
}
