import Foundation

extension String {
    /// First letter in capitals, the rest as it is: "tháng 10 năm 2026" → "Tháng 10 năm 2026" for
    /// a heading (some languages write month names in lower case).
    var capitalizedFirstLetter: String {
        guard let first else { return self }
        return first.uppercased() + dropFirst()
    }
}
