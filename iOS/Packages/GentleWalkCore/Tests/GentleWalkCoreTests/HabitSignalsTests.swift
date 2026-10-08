import Foundation
import Testing
@testable import GentleWalkCore

/// P10 (plan 4.11): the reminder time and the session length follow what she actually does.
@Suite struct HabitSignalsTests {
    let ny = TestSupport.newYork
    func at(_ day: Int, _ hour: Int, _ minute: Int = 0) -> Date { TestSupport.local(ny, 2026, 10, day, hour, minute) }

    /// Five sessions in a row well after the reminder: offer to move it to her usual time (to 15 minutes).
    @Test func movesTheReminderAfterFiveSessionsAtAnotherTime() {
        let starts = [at(1, 9, 5), at(2, 9, 20), at(5, 9, 10), at(6, 9, 25), at(7, 9, 15)]
        #expect(HabitSignals.suggestedReminderMinutes(starts: starts, reminderMinutes: 8 * 60, calendar: ny) == 9 * 60 + 15)
        // Earlier than the reminder works the same way.
        let early = [at(1, 7, 0), at(2, 7, 10), at(5, 6, 55), at(6, 7, 5), at(7, 7, 0)]
        #expect(HabitSignals.suggestedReminderMinutes(starts: early, reminderMinutes: 8 * 60 + 30, calendar: ny) == 7 * 60)
    }

    @Test func keepsTheReminderWhenTheTimesAreCloseMixedOrFew() {
        let close = [at(1, 8, 20), at(2, 8, 40), at(5, 8, 50), at(6, 8, 10), at(7, 8, 30)]
        #expect(HabitSignals.suggestedReminderMinutes(starts: close, reminderMinutes: 8 * 60 + 30, calendar: ny) == nil)
        let mixed = [at(1, 7, 0), at(2, 10, 0), at(5, 7, 0), at(6, 10, 0), at(7, 10, 0)]
        #expect(HabitSignals.suggestedReminderMinutes(starts: mixed, reminderMinutes: 8 * 60 + 30, calendar: ny) == nil)
        let four = [at(1, 10, 0), at(2, 10, 0), at(5, 10, 0), at(6, 10, 0)]
        #expect(HabitSignals.suggestedReminderMinutes(starts: four, reminderMinutes: 8 * 60, calendar: ny) == nil)
        // Only the latest five count: an old habit does not decide.
        let old = [at(1, 15, 0), at(2, 15, 0)] + close.map { $0.addingTimeInterval(7 * 86_400) }
        #expect(HabitSignals.suggestedReminderMinutes(starts: old, reminderMinutes: 8 * 60 + 30, calendar: ny) == nil)
    }

    func session(_ day: Int, done: Double, pain: Bool = false, extra: Bool = false) -> SessionTiming {
        SessionTiming(start: at(day, 9), plannedSeconds: 600, activeSeconds: Int(600 * done), stoppedForPain: pain,
                      extraAfter: extra)
    }

    /// Two of the last three ended at 60–85 % (not for pain): next ones a little shorter.
    @Test func endingEarlyTwiceMakesItShorter() {
        #expect(HabitSignals.lengthSignal([session(1, done: 1), session(2, done: 0.7), session(5, done: 0.8)]) == .shorter)
        #expect(HabitSignals.lengthSignal([session(1, done: 0.7), session(2, done: 1), session(5, done: 1)]) == nil)
        // Stopping for pain is not a length signal (pain rules handle it).
        #expect(HabitSignals.lengthSignal([session(1, done: 0.7, pain: true), session(2, done: 0.8, pain: true),
                                           session(5, done: 1)]) == nil)
        // Under 60 % is not "a bit long": that is a stop, not a pattern.
        #expect(HabitSignals.lengthSignal([session(1, done: 0.3), session(2, done: 0.4), session(5, done: 1)]) == nil)
    }

    /// An extra right after the session twice in the last three: suggest the longer walk.
    @Test func extrasRightAfterSuggestLonger() {
        #expect(HabitSignals.lengthSignal([session(1, done: 1, extra: true), session(2, done: 1), session(5, done: 1, extra: true)])
            == .longer)
        #expect(HabitSignals.lengthSignal([session(1, done: 1, extra: true), session(2, done: 1)]) == nil)
        // Shorter wins: never longer and shorter at once.
        #expect(HabitSignals.lengthSignal([session(1, done: 0.7, extra: true), session(2, done: 0.8, extra: true),
                                           session(5, done: 1)]) == .shorter)
    }
}
