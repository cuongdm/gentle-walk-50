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
                .accessibilityAddTraits(.isHeader)
            if let subtitle {
                Text(verbatim: subtitle).typeRole(.body).foregroundStyle(Palette.text)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
