import SwiftUI
import UIKit
import GentleWalkCore

// Complete (S15) under the title, after Claude Design "Session complete" (plan 08/10/2026 task 3.6):
// the three numbers in one paper card split by dashed lines (numbers in SF Pro Rounded, an icon each),
// the next postcard as a small tilted postcard with a stamp, and the tree line on a green wash.

/// Three numbers side by side in one card; stacked at accessibility text sizes.
struct CompleteStats: View {
    let minutes: Int
    let milesText: String
    let milesLabel: String
    let activeDays: Int
    /// Journey miles indoors, the walk itself outdoors.
    var milesIcon: AppIcon = .journey

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        let stacked = typeSize.isAccessibilitySize
        let layout = stacked ? AnyLayout(VStackLayout(spacing: 10)) : AnyLayout(HStackLayout(spacing: 0))
        layout {
            StatColumn(icon: .time, value: String(localized: "\(minutes) min"), label: String(localized: "moving"))
            StatDivider(vertical: !stacked)
            StatColumn(icon: milesIcon, value: milesText, label: milesLabel)
            StatDivider(vertical: !stacked)
            StatColumn(icon: .activeDay, value: "\(activeDays)", label: Plural.activeDaysLabel(activeDays))
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 6)
        .frame(maxWidth: .infinity)
        .background { CardPaper() }
    }
}

/// One number: its icon and the figure on one line, the words under it.
private struct StatColumn: View {
    let icon: AppIcon
    let value: String
    let label: String

    @Environment(\.colorScheme) private var scheme
    @ScaledMetric(relativeTo: .callout) private var iconSize: CGFloat = 17

    var body: some View {
        VStack(spacing: 2) {
            Text(verbatim: value).typeRole(.statCompact).foregroundStyle(ChoiceInk.glyph(scheme))
                .lineLimit(1).minimumScaleFactor(0.6)
            // The icon sits with the words, so the number keeps the whole column (iPhone SE).
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                icon.image.resizable().scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .alignmentGuide(.firstTextBaseline) { $0[.bottom] - iconSize * 0.15 }
                    .foregroundStyle(ChoiceInk.glyph(scheme))
                    .accessibilityHidden(true)
                Text(verbatim: label).typeRole(.caption).foregroundStyle(Palette.textMuted)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

/// The dashed line between the numbers (and between stacked rows at large text sizes).
struct StatDivider: View {
    var vertical = true

    var body: some View {
        Group {
            if vertical {
                Line(vertical: true).stroke(style: StrokeStyle(lineWidth: 1.5, dash: [4, 4])).frame(width: 1.5)
            } else {
                Line(vertical: false).stroke(style: StrokeStyle(lineWidth: 1.5, dash: [4, 4])).frame(height: 1.5)
            }
        }
        .foregroundStyle(Palette.textMuted.opacity(0.35))
        .accessibilityHidden(true)
    }

    private struct Line: Shape {
        let vertical: Bool
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: vertical ? rect.midX : rect.minX, y: vertical ? rect.minY : rect.midY))
            path.addLine(to: CGPoint(x: vertical ? rect.midX : rect.maxX, y: vertical ? rect.maxY : rect.midY))
            return path
        }
    }
}

/// "Next postcard: Times Square." · "0.4 mi to go. Every minute you move takes you there.", beside the
/// last postcard she reached, tilted, with its stamp. Stacked at accessibility text sizes.
struct NextPostcardRow: View {
    let next: String
    let milesToGo: String
    let lastStop: Journey.Stop?

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        let layout = typeSize.isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
                                                  : AnyLayout(HStackLayout(alignment: .center, spacing: 16))
        layout {
            if let lastStop {
                MiniPostcard(stop: lastStop)
            } else {
                AppIconChip(icon: .journey)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Next postcard: \(next).").typeRole(.body).fontWeight(.semibold).foregroundStyle(Palette.text)
                Text("\(milesToGo) to go. Every minute you move takes you there.")
                    .typeRole(.caption).foregroundStyle(Palette.textMuted)
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }
}

/// A small postcard: white border, its painting, the place in italics, a slight tilt and a stamp.
private struct MiniPostcard: View {
    let stop: Journey.Stop

    private var imageName: String? {
        [Art.postcardName(stopID: stop.id), Art.coverName(stopID: stop.id)].first { UIImage(named: $0) != nil }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Group {
                if let imageName {
                    Image(imageName).resizable().scaledToFill()
                } else {
                    Palette.sky.opacity(0.3)
                }
            }
            .frame(width: 112, height: 78)
            .clipped()
            Text(verbatim: stop.name).typeRole(.caption).italic().foregroundStyle(Palette.textMuted)
                .lineLimit(1).minimumScaleFactor(0.7)
                .frame(width: 112, alignment: .leading)
        }
        .padding(6)
        .background(Palette.surface)
        .shadow(color: Palette.shadow.opacity(0.16), radius: 10, y: 5)
        .overlay(alignment: .topTrailing) { PostcardStamp(size: 30).offset(x: 10, y: -10) }
        .rotationEffect(.degrees(-4))
        .padding(.leading, 4)
        .accessibilityHidden(true)
    }
}

/// The round "reached" stamp on a postcard: a dashed sienna ring with a tick.
struct PostcardStamp: View {
    var size: CGFloat = 34

    var body: some View {
        ZStack {
            Circle().fill(Palette.surface)
            Circle().strokeBorder(Palette.accent, style: StrokeStyle(lineWidth: 1.6, dash: [2.4, 2.4]))
            Image(systemName: "checkmark").font(.system(size: size * 0.38, weight: .bold)).foregroundStyle(Palette.accent)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

/// The route line when no next postcard is ahead (route finished, or the free leg ends here).
struct CompleteJourneyLine: View {
    let text: String
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label { Text(verbatim: text) } icon: { AppIconChip(icon: .journey) }
                .typeRole(.body).foregroundStyle(Palette.text)
            ProgressView(value: progress).tint(Palette.secondary).accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
    }
}

/// "6 of 7 active days to Sprout" beside the tree, on a soft green wash.
struct CompleteTreeLine: View {
    let activeDays: Int
    @ScaledMetric(relativeTo: .body) private var treeSize: CGFloat = 58

    var body: some View {
        if let milestone = TreeLevel.milestone(activeDays: activeDays) {
            let level = TreeLevel.level(activeDays: activeDays)
            HStack(spacing: 12) {
                Group {
                    if let image = UIImage(named: Art.treeName(level: level)) {
                        TreeBadge(name: Art.treeName(level: level), imageSize: image.size,
                                  content: Art.treeContentRect(level: level), side: treeSize)
                    } else {
                        AppIcon.sprout.image.resizable().scaledToFit().foregroundStyle(Palette.secondary)
                    }
                }
                .frame(width: treeSize, height: treeSize)
                .accessibilityHidden(true)
                Text(verbatim: TreeMilestoneLine.text(milestone)).typeRole(.body).foregroundStyle(Palette.text)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background {
                RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
                    .fill(LinearGradient(colors: [Palette.secondary.opacity(0.16), Palette.secondary.opacity(0.07)],
                                         startPoint: .top, endPoint: .bottom))
            }
        }
    }
}

/// The tree painting cropped to the plant itself and centred in a square, so a seed or sprout is not
/// a speck at the foot of a tall sheet of paper. In light mode it multiplies into the green wash; in
/// dark mode it sits on its own paper tile, since multiplied onto a dark fill it turns black (review M5-D).
private struct TreeBadge: View {
    let name: String
    let imageSize: CGSize
    /// The painted part of the image, as a share of its width and height.
    let content: CGRect
    let side: CGFloat

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let inset: CGFloat = scheme == .dark ? 6 : 0
        let box = side - inset * 2
        let aspect = imageSize.height > 0 ? imageSize.width / imageSize.height : 1
        // Rendered image height that makes the painted part fill the box on its longer side.
        let height = min(box / max(content.height, 0.01), box / max(content.width * aspect, 0.01))
        let width = height * aspect
        let art = Image(name)
            .resizable()
            .frame(width: width, height: height)
            .offset(x: (0.5 - content.midX) * width, y: (0.5 - content.midY) * height)
            .frame(width: box, height: box)
            .clipped()
        if scheme == .dark {
            art.blendMode(.multiply)
                .padding(inset)
                .background(Palette.artPaper, in: .rect(cornerRadius: 12, style: .continuous))
                .compositingGroup()
        } else {
            art.blendMode(.multiply)
        }
    }
}
