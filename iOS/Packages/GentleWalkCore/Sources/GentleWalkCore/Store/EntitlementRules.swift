import Foundation

/// Product identifiers (App Store Connect, the RevenueCat offering and App/GentleWalk.storekit).
public enum ProductID {
    public static let yearly = "com.kmd.goodfooting.pro.yearly"
    public static let monthly = "com.kmd.goodfooting.pro.monthly"
    public static let lifetime = "com.kmd.goodfooting.pro.lifetime"
    public static let subscriptions: Set<String> = [yearly, monthly]
    public static let all: [String] = [yearly, monthly, lifetime]
}
