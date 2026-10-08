import Foundation

/// Product identifiers (App Store Connect, the RevenueCat offering and App/GentleWalk.storekit).
public enum ProductID {
    public static let yearly = "com.kmd.gentlewalk.pro.yearly"
    public static let monthly = "com.kmd.gentlewalk.pro.monthly"
    public static let lifetime = "com.kmd.gentlewalk.pro.lifetime"
    public static let subscriptions: Set<String> = [yearly, monthly]
    public static let all: [String] = [yearly, monthly, lifetime]
}
