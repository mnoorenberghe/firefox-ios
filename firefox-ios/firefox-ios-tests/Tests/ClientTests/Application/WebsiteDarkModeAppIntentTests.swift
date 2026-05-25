// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import AppIntents
import XCTest
@testable import Client

@MainActor
@available(iOS 17.0, *)
final class WebsiteDarkModeAppIntentTests: XCTestCase {
    private var windowManager: MockWindowManager!
    private var tabManager: MockTabManager!
    private var tab: MockTab!

    override func setUp() async throws {
        try await super.setUp()

        tabManager = MockTabManager()
        windowManager = MockWindowManager(
            wrappedManager: WindowManagerImplementation(),
            tabManager: tabManager
        )
        DependencyHelperMock().bootstrapDependencies(
            injectedWindowManager: windowManager,
            injectedTabManager: tabManager
        )

        tab = MockTab(profile: MockProfile(), windowUUID: .XCTestDefaultUUID)
        tab.webView = MockTabWebView(tab: tab)
        tabManager.tabs = [tab]
        NightModeHelper.turnOff()
    }

    override func tearDown() async throws {
        NightModeHelper.turnOff()
        DependencyHelperMock().reset()
        tab = nil
        tabManager = nil
        windowManager = nil
        try await super.tearDown()
    }

    func testPerform_whenStateIsOn_enablesWebsiteDarkMode() async throws {
        _ = try await SetWebsiteDarkModeIntent(state: .on).perform()

        XCTAssertTrue(NightModeHelper.isActivated())
        XCTAssertTrue(tab.nightMode)
        XCTAssertEqual(tab.webView?.scrollView.indicatorStyle, .white)
    }

    func testPerform_whenStateIsOff_disablesWebsiteDarkMode() async throws {
        NightModeHelper.setNightMode(enabled: true)

        _ = try await SetWebsiteDarkModeIntent(state: .off).perform()

        XCTAssertFalse(NightModeHelper.isActivated())
        XCTAssertFalse(tab.nightMode)
        XCTAssertEqual(tab.webView?.scrollView.indicatorStyle, .default)
    }

    func testFirefoxAppShortcutsProvider_exposesWebsiteDarkModeShortcut() {
        let shortcuts = FirefoxAppShortcutsProvider.appShortcuts

        XCTAssertEqual(shortcuts.count, 1)
        XCTAssertTrue(shortcuts[0].intent is SetWebsiteDarkModeIntent)
    }
}
