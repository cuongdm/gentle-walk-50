/// Applies the S06 body limits to exercises: hidden ones are never offered, some start easier.
public enum BodyLimitFilter {
    /// Exercises not hidden for any of the limits, in their original order.
    public static func allowed(_ exercises: [Exercise], limits: Set<BodyLimit>) -> [Exercise] {
        exercises.filter { limits.isDisjoint(with: $0.hiddenFor) }
    }

    /// True when one of the limits makes the easier version the default.
    public static func startsEasier(_ exercise: Exercise, limits: Set<BodyLimit>) -> Bool {
        !limits.isDisjoint(with: exercise.easierFor)
    }
}
