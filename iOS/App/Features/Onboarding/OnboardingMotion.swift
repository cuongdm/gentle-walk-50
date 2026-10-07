import SwiftUI
import GentleWalkCore

// Motion for the onboarding redesign (owner 03/10/2026, prototype "Gentle Walk onboarding redesign"):
// every move is under 0.6 s, nothing advances by itself, and Reduce Motion leaves only fades.

/// How an element arrives the first time it appears.
enum RevealStyle {
    /// Rises 14 pt while fading in.
    case rise
    /// Grows from half size with a small overshoot (week tiles, timeline dots).
    case pop
    /// Drops 10 pt from above (limit chips landing in the plan).
    case drop
}

private struct RevealOnAppear: ViewModifier {
    let style: RevealStyle
    let delay: Double
    let enabled: Bool
    @State private var shown = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @ViewBuilder func body(content: Content) -> some View {
        if enabled { animated(content) } else { content }
    }

    private func animated(_ content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .scaleEffect(shown || reduceMotion || style != .pop ? 1 : 0.5)
            .offset(y: shown || reduceMotion ? 0 : (style == .rise ? 14 : style == .drop ? -10 : 0))
            .onAppear {
                let animation: Animation = reduceMotion ? .easeOut(duration: 0.25)
                    : style == .pop ? .spring(response: 0.42, dampingFraction: 0.62) : .spring(response: 0.5, dampingFraction: 0.86)
                withAnimation(animation.delay(reduceMotion ? 0 : delay)) { shown = true }
            }
    }
}

extension View {
    /// Fades the view in (and moves it a little, unless Reduce Motion is on) when it first appears.
    func reveal(_ style: RevealStyle = .rise, delay: Double = 0, enabled: Bool = true) -> some View {
        modifier(RevealOnAppear(style: style, delay: delay, enabled: enabled))
    }
}

/// The coach's round face, cut from the waving painting (head at the top of the picture).
struct CoachFace: View {
    var size: CGFloat = 44

    var body: some View {
        // The face sits in a 110 px square at (95, 15) of the 269 × 509 painting.
        let k = size / 110
        Image(Art.walkerWave.rawValue)
            .resizable()
            .frame(width: 269 * k, height: 509 * k)
            .offset(x: -95 * k, y: -15 * k)
            .frame(width: size, height: size, alignment: .topLeading)
            .background(Palette.artPaper)
            .clipShape(.circle)
            .overlay { Circle().strokeBorder(Palette.secondary.opacity(0.35), lineWidth: 2) }
            .accessibilityHidden(true)
    }
}

/// The coach answers under the list: her face and one short line in a speech bubble. Rises in each
/// time the line changes; VoiceOver reads it once when it appears.
struct CoachNote: View {
    let text: LocalizedStringResource

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            CoachFace()
            Text(text)
                .typeRole(.body)
                .foregroundStyle(Palette.text)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Palette.surface, in: UnevenRoundedRectangle(topLeadingRadius: 4, bottomLeadingRadius: 18,
                                                                         bottomTrailingRadius: 18, topTrailingRadius: 18))
                .overlay {
                    UnevenRoundedRectangle(topLeadingRadius: 4, bottomLeadingRadius: 18, bottomTrailingRadius: 18, topTrailingRadius: 18)
                        .strokeBorder(Palette.secondary.opacity(0.25), lineWidth: 1.5)
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .id(String(localized: text))
        .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
    }
}

/// A gentle winding path across the header: the walked part drawn in sap green, a small walker at
/// the front (goal gradient: never at 0), three dots where the parts begin.
struct WalkingPathProgress: View {
    /// 0...1.
    let progress: Double
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var bob = false

    private static let partStarts: [Double] = [1.0 / 8, 4.0 / 8, 7.0 / 8]

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack(alignment: .topLeading) {
                WindingPath()
                    .stroke(Palette.secondary.opacity(0.25), style: StrokeStyle(lineWidth: 5, lineCap: .round, dash: [1, 9]))
                WindingPath()
                    .trim(from: 0, to: progress)
                    .stroke(Palette.secondary, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                ForEach(Self.partStarts, id: \.self) { start in
                    Circle()
                        .fill(progress >= start ? Palette.secondary : Palette.textMuted.opacity(0.35))
                        .overlay { Circle().strokeBorder(Palette.bg, lineWidth: 2) }
                        .frame(width: 11, height: 11)
                        .position(WindingPath.point(at: start, in: size))
                }
                Image(systemName: "figure.walk")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Palette.primary)
                    .frame(width: 26, height: 26)
                    .background(Palette.surface, in: .circle)
                    .overlay { Circle().strokeBorder(Palette.primary, lineWidth: 2.5) }
                    .offset(y: bob ? -2.5 : 0)
                    .position(WindingPath.point(at: progress, in: size))
            }
        }
        .frame(height: 34)
        .animation(reduceMotion ? .easeInOut(duration: 0.2) : .easeInOut(duration: 0.7), value: progress)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true)) { bob = true }
        }
        .accessibilityHidden(true)
    }
}

/// One and a half soft waves from edge to edge; `point(at:)` follows its length, so the walker sits
/// exactly on the end of the trimmed stroke.
struct WindingPath: Shape {
    private static let samples = 140

    private static func raw(_ t: Double, in size: CGSize) -> CGPoint {
        let inset: CGFloat = 13
        let x = inset + (size.width - 2 * inset) * CGFloat(t)
        let y = size.height / 2 + 7 * CGFloat(sin(t * .pi * 3))
        return CGPoint(x: x, y: y)
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: Self.raw(0, in: rect.size))
        for i in 1...Self.samples { path.addLine(to: Self.raw(Double(i) / Double(Self.samples), in: rect.size)) }
        return path
    }

    /// The point a share `fraction` of the way along the path's length.
    static func point(at fraction: Double, in size: CGSize) -> CGPoint {
        let points = (0...samples).map { raw(Double($0) / Double(samples), in: size) }
        var lengths: [CGFloat] = [0]
        for i in 1..<points.count { lengths.append(lengths[i - 1] + hypot(points[i].x - points[i - 1].x, points[i].y - points[i - 1].y)) }
        let target = (lengths.last ?? 0) * CGFloat(min(1, max(0, fraction)))
        guard let index = lengths.firstIndex(where: { $0 >= target }), index > 0 else { return points[0] }
        let span = lengths[index] - lengths[index - 1]
        let t = span > 0 ? (target - lengths[index - 1]) / span : 0
        return CGPoint(x: points[index - 1].x + (points[index].x - points[index - 1].x) * t,
                       y: points[index - 1].y + (points[index].y - points[index - 1].y) * t)
    }
}

/// A small drawn figure beside the body question: the areas she chose glow softly. Illustration
/// only, not a control (the chips below are the way to choose).
struct BodyGlowFigure: View {
    let limits: Set<BodyLimit>
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulse = false

    /// Glow centres on a 100 × 180 figure.
    private static func spots(_ limit: BodyLimit) -> [CGPoint] {
        switch limit {
        case .knees: [CGPoint(x: 39, y: 126), CGPoint(x: 61, y: 126)]
        case .hips: [CGPoint(x: 38, y: 90), CGPoint(x: 62, y: 90)]
        case .lowerBack: [CGPoint(x: 50, y: 80)]
        case .shoulders: [CGPoint(x: 32, y: 44), CGPoint(x: 68, y: 44)]
        default: []
        }
    }

    var body: some View {
        Canvas { context, size in
            let s = min(size.width / 100, size.height / 180)
            let ox = (size.width - 100 * s) / 2
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: ox + x * s, y: y * s) }
            var figure = Path()
            figure.addEllipse(in: CGRect(x: ox + 38 * s, y: 6 * s, width: 24 * s, height: 24 * s))
            figure.move(to: p(32, 40)); figure.addQuadCurve(to: p(68, 40), control: p(50, 32))
            figure.addLine(to: p(74, 84)); figure.addQuadCurve(to: p(26, 84), control: p(50, 92)); figure.closeSubpath()
            for (a, b) in [(p(32, 42), p(20, 82)), (p(68, 42), p(80, 82)), (p(40, 86), p(36, 172)), (p(60, 86), p(64, 172))] {
                figure.move(to: a); figure.addLine(to: b)
            }
            context.fill(figure, with: .color(Palette.surface))
            context.stroke(figure, with: .color(Palette.textMuted), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
        }
        .overlay {
            GeometryReader { proxy in
                let s = min(proxy.size.width / 100, proxy.size.height / 180)
                let ox = (proxy.size.width - 100 * s) / 2
                ForEach(OnboardingCopy.limitOrder.filter(limits.contains), id: \.rawValue) { limit in
                    ForEach(Array(Self.spots(limit).enumerated()), id: \.offset) { _, spot in
                        Circle()
                            .fill(Palette.sun.opacity(pulse ? 0.3 : 0.55))
                            .frame(width: 18 * s * (pulse ? 1.3 : 1), height: 18 * s * (pulse ? 1.3 : 1))
                            .position(x: ox + spot.x * s, y: spot.y * s)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: limits)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) { pulse = true }
        }
        .accessibilityHidden(true)
    }
}
