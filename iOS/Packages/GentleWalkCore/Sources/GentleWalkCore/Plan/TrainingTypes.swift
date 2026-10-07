/// Walking level (spec S05/S07): Seated is the default; the walking pad is the user's own choice.
public enum WalkLevel: String, CaseIterable, Codable, Sendable {
    case seated, inPlace = "inplace", pad

    /// One step easier, or nil at Seated.
    public var easier: WalkLevel? {
        switch self {
        case .seated: nil
        case .inPlace: .seated
        case .pad: .inPlace
        }
    }

    /// One step harder. Only Seated moves up automatically; the pad needs equipment, so it is never
    /// chosen for the user.
    public var harder: WalkLevel? { self == .seated ? .inPlace : nil }
}

/// Today's intensity from the check-in: it changes only brisk-phase length and move count.
public enum Intensity: String, CaseIterable, Codable, Sendable {
    case gentle, steady, strong

    public init(checkIn: CheckIn) {
        switch checkIn {
        case .achy: self = .gentle
        case .okay: self = .steady
        case .great: self = .strong
        }
    }

    /// Stretch hold per side (A10 §1). Changed 06/10/2026 for women 58–75 (review
    /// docs/reviews/2026-10-06-chuyen-gia-ra-soat-bai-tap-58-75.md Q4): Gentle 20 s, Steady and Strong 30 s,
    /// with a second round for the key poses so each main muscle group gets 40–60 s.
    public var stretchHoldSeconds: Int {
        switch self {
        case .gentle: 20
        case .steady, .strong: 30
        }
    }
}

/// "How do your joints feel today?" (S17).
public enum CheckIn: String, CaseIterable, Codable, Sendable { case achy, okay, great }
