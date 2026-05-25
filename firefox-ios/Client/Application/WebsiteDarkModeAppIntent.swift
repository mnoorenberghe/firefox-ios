// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import AppIntents
import Foundation

@available(iOS 17.0, *)
enum WebsiteDarkModeState: String, AppEnum {
    case on
    case off

    static let typeDisplayRepresentation = TypeDisplayRepresentation(
        name: LocalizedStringResource(
            "Settings.Appearance.WebsiteDarkModeToggle.Title.v137",
            defaultValue: "Website Dark Mode"
        )
    )

    static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .on: DisplayRepresentation(title: "On"),
        .off: DisplayRepresentation(title: "Off")
    ]

    var isEnabled: Bool {
        return self == .on
    }
}

@available(iOS 17.0, *)
struct SetWebsiteDarkModeIntent: AppIntent {
    static let title = LocalizedStringResource(
        "Settings.Appearance.WebsiteDarkModeToggle.Title.v137",
        defaultValue: "Website Dark Mode"
    )

    static let description = IntentDescription(
        LocalizedStringResource(
            "Settings.Appearance.WebsiteDarkMode.Description.v137",
            defaultValue: "Gives websites a dark appearance. Some sites might not look right."
        )
    )

    static let openAppWhenRun = false

    @Parameter(title: "State")
    var state: WebsiteDarkModeState

    static var parameterSummary: some ParameterSummary {
        Summary("Set Website Dark Mode to \(\.$state)")
    }

    init() {}

    init(state: WebsiteDarkModeState) {
        self.state = state
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        await MainActor.run {
            NightModeHelper.setNightMode(enabled: state.isEnabled)
        }

        let dialog: IntentDialog = state == .on
            ? "Website Dark Mode turned on."
            : "Website Dark Mode turned off."
        return .result(dialog: dialog)
    }
}

@available(iOS 17.0, *)
struct FirefoxAppShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        [
            AppShortcut(
                intent: SetWebsiteDarkModeIntent(),
                phrases: [
                    "Set Website Dark Mode in \(.applicationName)",
                    "Change Website Dark Mode in \(.applicationName)"
                ],
                shortTitle: LocalizedStringResource(
                    "Settings.Appearance.WebsiteDarkModeToggle.Title.v137",
                    defaultValue: "Website Dark Mode"
                ),
                systemImageName: "moon.fill"
            )
        ]
    }
}
