/// Version of the bundled content JSON schema (exercises, journeys, sessions, voice lines).
/// Bump when the JSON shape changes so `ContentValidator` can reject stale bundles.
public enum CoreInfo {
    public static let contentSchemaVersion = 1
}
