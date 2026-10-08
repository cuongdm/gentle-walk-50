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
/// At accessibility text sizes Close takes its own row above the title, so the title gets the full
/// width and wraps between words ("Wednesday, October 7" broke mid-word beside Close, review M5-D).
struct ClosableHeader: View {
    let title: String
    var subtitle: String? = nil
    let onClose: () -> Void

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        if typeSize.isAccessibilitySize {
            VStack(alignment: .trailing, spacing: 4) {
                closeButton
                VStack(alignment: .leading, spacing: 6) {
                    // Capped so a long single word (a weekday, a month) still fits one line on a small phone.
                    Text(verbatim: title)
                        .typeRole(.screenTitle)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                        .foregroundStyle(Palette.text)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
                    if let subtitle {
                        Text(verbatim: subtitle).typeRole(.body).foregroundStyle(Palette.text)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilitySortPriority(1)
            }
            .accessibilityElement(children: .contain)
        } else {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                ScreenHeaderText(title: title, subtitle: subtitle)
                closeButton
            }
        }
    }

    private var closeButton: some View {
        Button("Close", action: onClose).buttonStyle(.smallTextLink).fixedSize()
    }
}
