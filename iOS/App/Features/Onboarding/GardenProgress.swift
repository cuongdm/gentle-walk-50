import SwiftUI

/// Onboarding progress as a garden bed of seven plots (Claude Design `progress-metaphors.png`, owner
/// 08/10/2026), one per question: a plot she has passed holds its plant in sap green (seed → sprout →
/// two leaves → bush → bud → small flower → full flower, so the row grows as she goes), the current plot
/// is larger, deep green on an ochre halo, and the plots ahead are bare mounds of earth. It ties to the
/// tree on Progress. Decorative: the "Step 3 of 7" words beside it carry the meaning for VoiceOver.
struct GardenProgress: View {
    /// 1...7: the current question; 7 on Your plan, where the whole row has grown.
    let step: Int
    var total = 7

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Canvas { context, size in
            let slot = size.width / CGFloat(total)
            let ground = size.height - 5
            var line = Path()
            line.move(to: CGPoint(x: 2, y: ground + 1))
            line.addCurve(to: CGPoint(x: size.width - 2, y: ground - 1), control1: CGPoint(x: size.width * 0.35, y: ground - 2),
                          control2: CGPoint(x: size.width * 0.65, y: ground + 3))
            context.stroke(line, with: .color(Palette.textMuted.opacity(0.35)), style: StrokeStyle(lineWidth: 2, lineCap: .round))
            for index in 0..<total {
                let center = CGPoint(x: slot * (CGFloat(index) + 0.5), y: ground)
                let stage = index + 1
                if stage < step {
                    Plant.draw(stage: stage, at: center, scale: 1.0, ink: Palette.secondary, in: &context)
                } else if stage == step {
                    let halo = CGRect(x: center.x - 17, y: center.y - 33, width: 34, height: 34)
                    context.fill(Path(ellipseIn: halo), with: .color(Palette.sun.opacity(0.3)))
                    Plant.draw(stage: stage, at: center, scale: 1.3, ink: Palette.primary, in: &context)
                } else {
                    Plant.mound(at: center, in: &context)
                }
            }
        }
        .frame(height: 40)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.4), value: step)
        .accessibilityHidden(true)
    }
}

/// The seven plant drawings, standing on the ground line at `base`, about 22 pt tall at scale 1.
private enum Plant {
    static func draw(stage: Int, at base: CGPoint, scale s: CGFloat, ink: Color, in context: inout GraphicsContext) {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: base.x + x * s, y: base.y - y * s) }
        let stroke = StrokeStyle(lineWidth: 1.8 * s, lineCap: .round, lineJoin: .round)
        if stage == 1 {
            // A seed in a dip of soil.
            context.fill(Path(ellipseIn: CGRect(x: base.x - 3 * s, y: base.y - 4 * s, width: 6 * s, height: 4 * s)),
                         with: .color(Palette.accent.opacity(0.85)))
            return
        }
        let height: CGFloat = [0, 0, 8, 12, 15, 17, 19, 21][min(stage, 7)]
        var stem = Path()
        stem.move(to: p(0, 0))
        stem.addLine(to: p(0, height))
        context.stroke(stem, with: .color(ink), style: stroke)
        // Leaves: one on a sprout, a pair from two leaves on, a second pair from the bush on.
        leaf(from: p(0, height * 0.55), toward: 1, size: 6.5 * s, ink: ink, in: &context)
        if stage >= 3 { leaf(from: p(0, height * 0.55), toward: -1, size: 6.5 * s, ink: ink, in: &context) }
        if stage >= 4 {
            leaf(from: p(0, height * 0.85), toward: 1, size: 5 * s, ink: ink, in: &context)
            leaf(from: p(0, height * 0.85), toward: -1, size: 5 * s, ink: ink, in: &context)
        }
        let top = p(0, height + 2)
        switch stage {
        case 5:
            // A bud.
            context.fill(Path(ellipseIn: CGRect(x: top.x - 3 * s, y: top.y - 3.5 * s, width: 6 * s, height: 6 * s)),
                         with: .color(Palette.sun))
        case 6, 7:
            // A flower: ochre petals round a sienna heart, fuller on the last plot.
            let petals = stage == 6 ? 5 : 6
            let radius = (stage == 6 ? 3.2 : 4.2) * s
            for k in 0..<petals {
                let angle = Double(k) / Double(petals) * 2 * .pi
                let c = CGPoint(x: top.x + CGFloat(cos(angle)) * radius, y: top.y + CGFloat(sin(angle)) * radius)
                context.fill(Path(ellipseIn: CGRect(x: c.x - radius * 0.8, y: c.y - radius * 0.8, width: radius * 1.6, height: radius * 1.6)),
                             with: .color(Palette.sun))
            }
            context.fill(Path(ellipseIn: CGRect(x: top.x - radius * 0.55, y: top.y - radius * 0.55, width: radius * 1.1, height: radius * 1.1)),
                         with: .color(Palette.accent))
        default:
            break
        }
    }

    private static func leaf(from start: CGPoint, toward side: CGFloat, size: CGFloat, ink: Color, in context: inout GraphicsContext) {
        let tip = CGPoint(x: start.x + side * size, y: start.y - size * 0.6)
        var path = Path()
        path.move(to: start)
        path.addQuadCurve(to: tip, control: CGPoint(x: start.x + side * size * 0.2, y: start.y - size * 0.9))
        path.addQuadCurve(to: start, control: CGPoint(x: start.x + side * size * 0.9, y: start.y + size * 0.1))
        context.fill(path, with: .color(ink))
    }

    /// A bare mound of earth with a little seed hole.
    static func mound(at base: CGPoint, in context: inout GraphicsContext) {
        var path = Path()
        path.move(to: CGPoint(x: base.x - 9, y: base.y + 0.5))
        path.addQuadCurve(to: CGPoint(x: base.x + 9, y: base.y + 0.5), control: CGPoint(x: base.x, y: base.y - 7))
        path.closeSubpath()
        context.fill(path, with: .color(Palette.textMuted.opacity(0.18)))
        context.stroke(path, with: .color(Palette.textMuted.opacity(0.4)), style: StrokeStyle(lineWidth: 1.3, lineJoin: .round))
        context.fill(Path(ellipseIn: CGRect(x: base.x - 1.3, y: base.y - 4.3, width: 2.6, height: 2.6)),
                     with: .color(Palette.textMuted.opacity(0.5)))
    }
}
