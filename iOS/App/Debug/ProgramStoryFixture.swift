#if DEBUG
import Foundation
import SwiftData
import GentleWalkCore

/// One consistent history for the stage-recap captures (plan 09/10/2026: `today-stage-recap`, `program-recaps`,
/// `program-finished-route`, `journey-with-stages`), replacing Margaret's base sessions: sessions on her
/// non-rest days from the program's first day up to yesterday, journey miles that add up session by session,
/// each postcard opened on the day her miles reached it, the next route chosen when one is walked, and a
/// 2-week check every 14 days. Today, Program, Journey and the finish screen then all tell the same story.
enum ProgramStory {
    /// Active minutes of a session in each stage: a little more as she goes, never by the calendar alone.
    static let minutesByStage = [7, 9, 11, 12]
    /// Routes in the order she walks them (Pro; the captures are subscribed).
    static let routes = ["jr.ny", "jr.smoky", "jr.camino"]
    static let checkCounts = [7, 8, 8, 9, 10, 10, 11]

    /// - Parameter programDays: days since week 1 began (22: week 4, the day after stage 1 ended).
    static func seed(_ context: ModelContext, now: Date, calendar: Calendar, programDays: Int, journeys: [Journey],
                     restDays: Set<Int>, reminderMinutes: Int) {
        for record in (try? context.fetch(FetchDescriptor<WorkoutRecord>())) ?? [] { context.delete(record) }
        for state in (try? context.fetch(FetchDescriptor<JourneyState>())) ?? [] { context.delete(state) }
        for unlock in (try? context.fetch(FetchDescriptor<PostcardUnlock>())) ?? [] { context.delete(unlock) }
        for check in (try? context.fetch(FetchDescriptor<SelfCheckRecord>())) ?? [] { context.delete(check) }
        for program in (try? context.fetch(FetchDescriptor<ProgramState>())) ?? [] { context.delete(program) }

        let today = calendar.startOfDay(for: now)
        // Week 1 begins with her first session, so on a day she trains.
        var start = calendar.date(byAdding: .day, value: -programDays, to: today) ?? today
        while restDays.contains(calendar.component(.weekday, from: start)) {
            start = calendar.date(byAdding: .day, value: -1, to: start) ?? start
        }
        let round = ProgramRound(start: start)
        context.insert(ProgramState(start: start))

        var routeIndex = 0
        var state = JourneyState(journeyID: routes[0], isCurrent: true, startedAt: start)
        context.insert(state)
        var sessions = 0
        var day = start
        var index = 0
        let lastDays = calendar.date(byAdding: .day, value: -3, to: today) ?? today
        while day < today {
            defer {
                day = calendar.date(byAdding: .day, value: 1, to: day) ?? today
                index += 1
            }
            guard !restDays.contains(calendar.component(.weekday, from: day)) else { continue }
            // A day off now and then, never in the last days (Today would say "Welcome back").
            if index % 9 == 4, day < lastDays { continue }
            guard let at = calendar.date(byAdding: .minute, value: reminderMinutes, to: day),
                  case .week(_, let stage) = ProgramCalendar.position(round, on: at, calendar: calendar) else { continue }
            sessions += 1
            let outdoors = sessions % 12 == 6
            let minutes = outdoors ? 20 : minutesByStage[stage.rawValue - 1]
            let outdoorMiles: Double? = outdoors ? 0.9 : nil
            let miles = ActivityDistance.miles(activeMinutes: Double(minutes), outdoorMiles: outdoorMiles)
            context.insert(WorkoutRecord(date: at, kind: outdoors ? "walk" : ["walk", "chair", "walk", "stretch"][sessions % 4],
                                         level: "seated", intensity: "steady", place: outdoors ? "outdoors" : "indoors",
                                         activeSeconds: minutes * 60, journeyMiles: miles, outdoorMiles: outdoorMiles))
            guard let journey = journeys.first(where: { $0.id == state.journeyID }) else { continue }
            let step = JourneyProgress.advance(journey: journey, from: state.miles, to: state.miles + miles)
            state.miles += miles
            for stop in step.unlocked {
                context.insert(PostcardUnlock(journeyID: journey.id, stopID: stop, unlockedAt: at, opened: true))
            }
            // A route walked: she picks the next one the same day; its first postcard opens with her next session.
            if step.isComplete, routeIndex + 1 < routes.count {
                state.completedAt = at
                state.isCurrent = false
                routeIndex += 1
                state = JourneyState(journeyID: routes[routeIndex], isCurrent: true, startedAt: at)
                context.insert(state)
            }
        }

        // A 2-week check every 14 days from her first session, with her hands, after the session.
        for (number, checkDay) in stride(from: 0, to: programDays, by: SelfCheckSchedule.intervalDays).enumerated() {
            guard let date = calendar.date(byAdding: .day, value: checkDay, to: start),
                  let at = calendar.date(byAdding: .minute, value: reminderMinutes + 20, to: date), at < now else { continue }
            context.insert(SelfCheckRecord(date: at, count: checkCounts[min(number, checkCounts.count - 1)], usedHands: true,
                                           week: number == 0 ? 0 : checkDay / 7 + 1))
        }
    }
}
#endif
