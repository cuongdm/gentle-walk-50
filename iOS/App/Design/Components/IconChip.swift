import SwiftUI

/// An SF Symbol on a soft watercolour wash: the leading icon of list rows and benefit lines. The
/// wash is a slightly uneven blob, never a perfect circle (Pigment, owner 03/10/2026: the tinted
/// circle behind every icon was the most "generated" look in the app).
struct IconChip: View {
    let symbol: String
    var tint: Color = Palette.secondary
    @ScaledMetric(relativeTo: .body) private var size: CGFloat = 44

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.45, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(tint.opacity(0.16), in: WashShape(variant: WashShape.variant(for: symbol)))
            .accessibilityHidden(true)
    }
}

/// A hand-painted blob: four soft lobes with uneven radii, picked per icon so neighbours differ.
struct WashShape: Shape {
    var variant: Int = 0

    /// Radii (as a share of the half size) of the four lobes, clockwise from the right, per variant.
    private static let lobes: [[CGFloat]] = [
        [1.00, 0.90, 0.97, 0.86],
        [0.92, 1.00, 0.86, 0.95],
        [0.88, 0.94, 1.00, 0.90],
        [0.97, 0.86, 0.92, 1.00],
    ]

    static func variant(for key: String) -> Int {
        key.unicodeScalars.reduce(0) { ($0 &+ Int($1.value)) % 997 } % lobes.count
    }

    func path(in rect: CGRect) -> Path {
        let r = Self.lobes[abs(variant) % Self.lobes.count]
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let hx = rect.width / 2, hy = rect.height / 2
        // Points at 0°, 90°, 180°, 270°, joined by curves whose control points sit near the corners.
        let points = (0..<4).map { i -> CGPoint in
            let a = Double(i) * .pi / 2
            return CGPoint(x: c.x + CGFloat(cos(a)) * hx * r[i], y: c.y + CGFloat(sin(a)) * hy * r[i])
        }
        var path = Path()
        path.move(to: points[0])
        for i in 0..<4 {
            let next = points[(i + 1) % 4]
            let a = Double(i) * .pi / 2 + .pi / 4
            let k: CGFloat = 1.32 * (r[i] + r[(i + 1) % 4]) / 2
            let control = CGPoint(x: c.x + CGFloat(cos(a)) * hx * k, y: c.y + CGFloat(sin(a)) * hy * k)
            path.addQuadCurve(to: next, control: control)
        }
        path.closeSubpath()
        return path
    }
}
