// Draws the placeholder app icon (task 9.3): sage background, a warm sun, a white walking figure.
// No Apple device or product imagery (5.2.5). Opaque, no alpha channel (App Store requirement).
// Replace with the designed icon before release.
// Usage: swiftc -o /tmp/make_icon iOS/scripts/make_placeholder_icon.swift && /tmp/make_icon <out.png>
import AppKit
import ImageIO
import UniformTypeIdentifiers

let path = CommandLine.arguments.dropFirst().first ?? "icon-1024.png"
let size = 1024
let space = CGColorSpace(name: CGColorSpace.sRGB)!
guard let cg = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0, space: space,
                         bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { fatalError("no context") }

cg.setFillColor(CGColor(srgbRed: 0x55 / 255, green: 0x7E / 255, blue: 0x5F / 255, alpha: 1))
cg.fill(CGRect(x: 0, y: 0, width: size, height: size))
cg.setFillColor(CGColor(srgbRed: 0xF2 / 255, green: 0xB8 / 255, blue: 0x4B / 255, alpha: 1))
cg.fillEllipse(in: CGRect(x: 610, y: 610, width: 290, height: 290))

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(cgContext: cg, flipped: false)
let configuration = NSImage.SymbolConfiguration(pointSize: 520, weight: .semibold)
    .applying(NSImage.SymbolConfiguration(paletteColors: [.white]))
if let symbol = NSImage(systemSymbolName: "figure.walk", accessibilityDescription: nil)?.withSymbolConfiguration(configuration) {
    let origin = NSPoint(x: (CGFloat(size) - symbol.size.width) / 2 - 40, y: (CGFloat(size) - symbol.size.height) / 2 - 40)
    symbol.draw(at: origin, from: .zero, operation: .sourceOver, fraction: 1)
}
NSGraphicsContext.restoreGraphicsState()

guard let image = cg.makeImage(),
      let destination = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL, UTType.png.identifier as CFString, 1, nil)
else { fatalError("no image") }
CGImageDestinationAddImage(destination, image, nil)
guard CGImageDestinationFinalize(destination) else { fatalError("write failed") }
print("wrote \(path)")
