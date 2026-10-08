import Foundation
import Testing
@testable import GentleWalkCore

/// P6 (plan 4.9, D11): two questions at the turn of the week shape the next week.
@Suite struct WeeklyCheckInTests {
    let ny = TestSupport.newYork
    func day(_ d: Int, _ hour: Int = 9) -> Date { TestSupport.local(ny, 2026, 10, d, hour) }
    var weekOf5: Date { ny.startOfDay(for: day(5)) }  // Monday 5 October 2026

    /// Asked on the first open from Sunday to Tuesday, about the Monday–Sunday week just gone.
    @Test func dueFromSundayToTuesdayAboutTheWeekGone() {
        let workouts = [day(6), day(8)]
        for d in [11, 12, 13] {
            #expect(WeeklyCheckIn.reviewedWeek(now: day(d), calendar: ny) == weekOf5, "Oct \(d)")
            #expect(WeeklyCheckIn.isDue(now: day(d), notes: [], workouts: workouts, calendar: ny), "Oct \(d)")
        }
        // Wednesday to Saturday: not asked.
        for d in [7, 8, 9, 10, 14] {
            #expect(!WeeklyCheckIn.isDue(now: day(d), notes: [], workouts: workouts + [day(12)], calendar: ny), "Oct \(d)")
        }
        // A week with no session: nothing to ask about.
        #expect(!WeeklyCheckIn.isDue(now: day(12), notes: [], workouts: [day(2)], calendar: ny))
    }

    /// Answered or skipped once: not asked again that week.
    @Test func answeredOrSkippedOnce() {
        let workouts = [day(6)]
        let skipped = WeeklyNote(weekStart: weekOf5, effort: nil, better: nil, answeredAt: day(11))
        #expect(!WeeklyCheckIn.isDue(now: day(12), notes: [skipped], workouts: workouts, calendar: ny))
        let older = WeeklyNote(weekStart: ny.startOfDay(for: TestSupport.local(ny, 2026, 9, 28)), effort: .right, better: nil,
                               answeredAt: day(4))
        #expect(WeeklyCheckIn.isDue(now: day(12), notes: [older], workouts: workouts, calendar: ny))
    }

    /// What each answer does to the next week.
    @Test func effectsOfEachAnswer() {
        func note(_ effort: WeeklyEffort?) -> WeeklyNote {
            WeeklyNote(weekStart: weekOf5, effort: effort, better: nil, answeredAt: day(11))
        }
        #expect(WeeklyCheckIn.effects(of: note(.harder)) == WeekEffects(minutesDelta: -2, defaultCheckIn: .achy, laddersFrozen: true))
        #expect(WeeklyCheckIn.effects(of: note(.easier)) == WeekEffects(minutesDelta: 2, defaultCheckIn: .great, laddersFrozen: false))
        #expect(WeeklyCheckIn.effects(of: note(.right)) == .none)
        #expect(WeeklyCheckIn.effects(of: note(nil)) == .none)
        #expect(WeeklyCheckIn.effects(of: nil) == .none)
    }

    /// The answer counts from when it is given until the end of the following week.
    @Test func answerShapesTheFollowingWeekOnly() {
        let note = WeeklyNote(weekStart: weekOf5, effort: .harder, better: .stairs, answeredAt: day(11, 10))
        #expect(WeeklyCheckIn.current(notes: [note], now: day(11, 9), calendar: ny) == nil)
        #expect(WeeklyCheckIn.current(notes: [note], now: day(14), calendar: ny) == note)
        #expect(WeeklyCheckIn.current(notes: [note], now: day(18, 23), calendar: ny) == note)
        #expect(WeeklyCheckIn.current(notes: [note], now: day(19), calendar: ny) == nil)
    }

    /// "Last week you said stairs felt a bit better." on Monday and Tuesday; never for "Nothing yet".
    @Test func lastWeekLineOnMondayAndTuesday() {
        let note = WeeklyNote(weekStart: weekOf5, effort: .right, better: .stairs, answeredAt: day(11))
        #expect(WeeklyCheckIn.lastWeekChip(notes: [note], now: day(12), calendar: ny) == .stairs)
        #expect(WeeklyCheckIn.lastWeekChip(notes: [note], now: day(13), calendar: ny) == .stairs)
        #expect(WeeklyCheckIn.lastWeekChip(notes: [note], now: day(14), calendar: ny) == nil)
        var nothing = note
        nothing.better = .nothingYet
        #expect(WeeklyCheckIn.lastWeekChip(notes: [nothing], now: day(12), calendar: ny) == nil)
    }

    /// Kept on the device: one note per week, the latest 24.
    @Test func keepsOnePerWeekAndTheLatest24() {
        var notes: [WeeklyNote] = []
        for week in 0..<30 {
            let start = ny.date(byAdding: .day, value: 7 * week, to: weekOf5)!
            notes = WeeklyCheckIn.adding(WeeklyNote(weekStart: start, effort: .right, better: nil, answeredAt: start), to: notes)
        }
        #expect(notes.count == WeeklyCheckIn.kept)
        let again = WeeklyNote(weekStart: notes.last!.weekStart, effort: .harder, better: nil, answeredAt: day(1))
        let replaced = WeeklyCheckIn.adding(again, to: notes)
        #expect(replaced.count == WeeklyCheckIn.kept && replaced.last?.effort == .harder)
        // Round-trips for UserDefaults.
        let data = try! JSONEncoder().encode(replaced)
        #expect(try! JSONDecoder().decode([WeeklyNote].self, from: data) == replaced)
    }

    /// Only "felt a bit better" words: no pain or medical wording in the chips (steady-claims).
    @Test func chipsAreClaimFree() {
        #expect(BetterChip.allCases.count == 7)
        for chip in BetterChip.allCases {
            for banned in ["pain", "relie", "cure", "heal", "fall"] {
                #expect(!chip.title.lowercased().contains(banned))
            }
        }
    }
}
