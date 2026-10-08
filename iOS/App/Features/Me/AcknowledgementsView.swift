import SwiftUI

/// Me → Help → Acknowledgements (plan 08/10/2026 task 3.4; `nguon-icon.md` §4): who made what the app
/// borrows. The icons are Phosphor Icons under the MIT licence, whose text must ship with the app; it is
/// read from the bundle (`Resources/Licenses/Phosphor-MIT.txt`, written by `tools/art/build_icons.py`).
struct AcknowledgementsView: View {
    /// The licence text, read once from the bundle when the screen appears (never in `body`).
    @State private var licence: String?

    var body: some View {
        MeDetailScreen(title: "Acknowledgements") {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    AppIconChip(icon: .acknowledgements)
                    Text(verbatim: "Phosphor Icons").typeRole(.cardTitle).accessibilityAddTraits(.isHeader)
                }
                Text("The icons in this app are Phosphor Icons, shared under the MIT License.").typeRole(.body)
                if let licence {
                    Text(verbatim: licence)
                        .typeRole(.caption)
                        .foregroundStyle(Palette.text)
                        .textSelection(.enabled)
                }
            }
            .foregroundStyle(Palette.text)
            .cardStyle()
        }
        .task { licence = Self.licenceText() }
    }

    static func licenceText(bundle: Bundle = .main) -> String? {
        guard let url = bundle.url(forResource: "Phosphor-MIT", withExtension: "txt"),
              let text = try? String(contentsOf: url, encoding: .utf8) else { return nil }
        // The file wraps at 80 columns (CRLF): join the lines of each paragraph so the words flow on a phone.
        return text.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "(?<!\n)\n(?!\n)", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
