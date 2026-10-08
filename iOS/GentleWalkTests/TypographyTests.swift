import SwiftUI
import Testing
@testable import GentleWalk

/// Font A1 (plan 08/10/2026 task 1.1, docs/design/research-2026-10-08/font-va-hinh-anh.md §3a):
/// New York for screen titles, SF Pro for text, SF Pro Rounded only for numbers; caption 16 pt.
@Suite struct TypographyTests {
    @Test func textRolesUseSFPro() {
        for role in [TypeRole.cardTitle, .body, .button, .caption] {
            #expect(role.design == .default, "\(role)")
        }
    }

    @Test func numberRolesUseRounded() {
        for role in [TypeRole.phaseLabel, .timer, .transition, .stat, .statCompact, .wallClock] {
            #expect(role.design == .rounded, "\(role)")
        }
    }

    @Test func titleIsSerif() {
        #expect(TypeRole.screenTitle.design == .serif)
    }

    @Test func captionIsSixteen() {
        #expect(TypeRole.caption.size == 16)
        #expect(TypeRole.caption.anchor == .callout)
        // Nothing is ever under 16 pt at the default size.
        #expect(TypeRole.allCases.allSatisfy { $0.size >= 16 })
    }

    @Test func timerIsMedium() {
        #expect(TypeRole.timer.weight == .medium)
        #expect(TypeRole.wallClock.weight == .medium)
    }

    /// Vietnamese stacked marks need a little room between lines (body and titles).
    @Test func bodyAndTitleHaveLineSpacing() {
        #expect(TypeRole.body.lineSpacing == 2)
        #expect(TypeRole.screenTitle.lineSpacing == 2)
        #expect(TypeRole.button.lineSpacing == 0)
    }
}
