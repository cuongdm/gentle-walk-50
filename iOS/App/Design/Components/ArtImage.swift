import SwiftUI
import UIKit
import GentleWalkCore

/// Painted illustrations in Assets.xcassets/Art, cut from the sheets in assets/art/ by
/// tools/art/build_art.py (names in tools/art/art-manifest.json). One character everywhere: the
/// coach from the exercise clips, drawn in gouache.
enum Art: String, CaseIterable, Sendable {
    // Figures on paper (fit inside the card).
    case walkerWave = "walker-wave"
    case walkerMarch = "walker-march"
    case walkerSeatedMarch = "walker-seated-march"
    case walkerCalfStretch = "walker-calf-stretch"
    case walkerCelebrate = "walker-celebrate"
    case walkerRest = "walker-rest"
    case walkerStand = "walker-stand"
    case walkerBehindChair = "walker-behind-chair"
    case phonePocket = "phone-pocket"
    case phoneChest = "phone-chest"
    case phoneTable = "phone-table"
    // Full scenes (fill the card).
    case sceneLivingRoom = "scene-living-room"
    case sceneWalkingPad = "scene-walking-pad"
    case sceneOutdoors = "scene-outdoors"
    case sceneBreak = "scene-break"
    case sceneParkBench = "scene-park-bench"
    case momentFriends = "moment-friends"
    case momentPlanNotebook = "moment-plan-notebook"
    case momentReadyDoor = "moment-ready-door"
    case mapPark = "map-park"
    /// "Coming next" journey (Route 66 in the content plan).
    case coverNext = "cover-next"

    var isBundled: Bool { UIImage(named: rawValue) != nil }

    /// Cover painting of a journey, named after its id ("jr.ny" → "cover-jr-ny"; asset names avoid dots).
    static func coverName(journeyID: String) -> String {
        "cover-\(journeyID.replacingOccurrences(of: ".", with: "-"))"
    }

    /// The painted part of each tree picture (the rest is paper), as a share of its width and height:
    /// measured on the PNGs in Assets.xcassets/Art (opaque, non-paper pixels), 09/10/2026.
    static func treeContentRect(level: TreeLevel) -> CGRect {
        switch level {
        case .seed: CGRect(x: 0.10, y: 0.78, width: 0.85, height: 0.18)
        case .sprout: CGRect(x: 0.0, y: 0.64, width: 0.82, height: 0.32)
        case .sapling: CGRect(x: 0.0, y: 0.26, width: 1.0, height: 0.70)
        case .tree: CGRect(x: 0.0, y: 0.07, width: 0.95, height: 0.89)
        }
    }

    /// Painting of the progress tree at a level ("tree-sprout").
    static func treeName(level: TreeLevel) -> String {
        switch level {
        case .seed: "tree-seed"
        case .sprout: "tree-sprout"
        case .sapling: "tree-sapling"
        case .tree: "tree-tree"
        }
    }

    /// Postcard painting of a stop ("pc.ny.zoo" → "postcard-pc-ny-zoo").
    static func postcardName(stopID: String) -> String {
        "postcard-\(stopID.replacingOccurrences(of: ".", with: "-"))"
    }

    /// Cover of the journey a stop belongs to ("pc.ny.zoo" → "cover-jr-ny"): the stand-in while
    /// that stop's postcard is not painted yet.
    static func coverName(stopID: String) -> String {
        let parts = stopID.split(separator: ".")
        return parts.count > 1 ? coverName(journeyID: "jr.\(parts[1])") : coverName(journeyID: stopID)
    }
}

extension String {
    /// Figures keep their paper margin; everything else is a full painting that fills its card.
    fileprivate var isFigureArt: Bool { hasPrefix("walker-") || hasPrefix("phone-") || hasPrefix("tree-") }
    /// The tree paintings carry their own paper, lighter than the card in dark mode: multiplied onto
    /// the card's paper they read as one picture (review M16, 02/10/2026).
    fileprivate var blendsIntoPaper: Bool { hasPrefix("tree-") }
    /// Scenes with people keep their top when cropped to a wider card, so heads never get cut;
    /// landscapes crop from the middle.
    fileprivate var cropAnchor: Alignment { hasPrefix("scene-") || hasPrefix("moment-") ? .top : .center }
}

/// A painted illustration on a rounded paper card. Falls back to the symbol placeholder when the
/// art is not in the catalog yet, so a missing file never leaves a hole in the layout.
struct ArtImage: View {
    /// Image set name in Assets.xcassets/Art.
    let name: String
    let height: CGFloat
    /// Second choice when `name` is not painted yet (a postcard falls back to its journey cover).
    let fallbackName: String?
    /// Placeholder symbol while no art is there at all.
    let fallbackSymbol: String
    /// Grow into the space the layout offers, from `minHeight` up to `height`.
    var minHeight: CGFloat?

    init(art: Art, height: CGFloat = 160, fallbackSymbol: String = "photo.artframe") {
        self.init(name: art.rawValue, height: height, fallbackSymbol: fallbackSymbol)
    }

    init(name: String, fallbackName: String? = nil, height: CGFloat = 160, fallbackSymbol: String = "photo.artframe") {
        self.name = name
        self.fallbackName = fallbackName
        self.height = height
        self.fallbackSymbol = fallbackSymbol
    }

    /// A picture that takes the free space of its stack, between `minHeight` and `maxHeight`.
    static func flexible(_ art: Art, minHeight: CGFloat, maxHeight: CGFloat, fallbackSymbol: String) -> ArtImage {
        var view = ArtImage(art: art, height: maxHeight, fallbackSymbol: fallbackSymbol)
        view.minHeight = minHeight
        return view
    }

    private var resolvedName: String? {
        [name, fallbackName].compactMap(\.self).first { UIImage(named: $0) != nil }
    }

    var body: some View {
        if let name = resolvedName {
            RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
                .fill(Palette.artPaper)
                .frame(maxWidth: .infinity)
                .frame(minHeight: minHeight ?? height, maxHeight: height)
                .overlay {
                    // A fixed frame the size of the card, so a filled picture overflows from its
                    // anchor (top for people) before the card clips it.
                    GeometryReader { proxy in
                        Image(name)
                            .resizable()
                            .aspectRatio(contentMode: name.isFigureArt ? .fit : .fill)
                            .blendMode(name.blendsIntoPaper ? .multiply : .normal)
                            .padding(name.isFigureArt ? 6 : 0)
                            .frame(width: proxy.size.width, height: proxy.size.height, alignment: name.cropAnchor)
                    }
                }
                .clipShape(.rect(cornerRadius: Metrics.cardRadius, style: .continuous))
                .accessibilityHidden(true)
        } else {
            IllustrationPlaceholder(symbol: fallbackSymbol, height: height)
        }
    }
}
