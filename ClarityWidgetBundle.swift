import WidgetKit
import SwiftUI
import AppIntents

@main
@available(iOS 16.1, *)
struct ClarityWidgetBundle: WidgetBundle {
    var body: some Widget {
        // Widget'lar buraya eklenecek
    }
}

// Intent handler registration
@available(iOS 16.0, *)
struct ClarityWidgetShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ToggleTimerIntent(),
            phrases: ["Toggle \(.applicationName) timer"],
            shortTitle: "Toggle Timer",
            systemImageName: "timer"
        )
    }
}
