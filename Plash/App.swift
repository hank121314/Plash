import Cocoa
import Combine
import AppCenter
import AppCenterCrashes
import Defaults
import Preferences

/*
TODO: When targeting macOS 11:
- Use `App` protocol.
- Use SwiftUI Settings window.
- Remove `Principal class` key in Info.plist. It's not needed anymore.
- Remove storyboard.
- Present windows using SwiftUI.
*/

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
	var cancellables = Set<AnyCancellable>()

	let menu = SSMenu()
	let powerSourceWatcher = PowerSourceWatcher()

	lazy var statusItem = with(NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)) {
		$0.isVisible = true
		$0.behavior = [.removalAllowed, .terminationOnRemoval]
		$0.menu = menu
		$0.button?.image = Constants.menuBarIcon
	}

	lazy var statusItemButton = statusItem.button!

	lazy var desktopMonitors = Defaults[.displays].reduce(into: [CGDirectDisplayID: DesktopMonitor]()) { memo, tuple in
		if tuple.value.isEnabled {
			memo[tuple.key] = DesktopMonitor(display: tuple.value)
		}
	}

	lazy var preferences: [PreferencePane] = [
		GeneralSettingsPane(),
		MonitorSettingsPane()
	]

	lazy var preferencesWindowController = PreferencesWindowController(
			preferencePanes: preferences,
			style: .toolbarItems,
			animated: true
	)

	func applicationWillFinishLaunching(_ notification: Notification) {
		UserDefaults.standard.register(defaults: [
			"NSApplicationCrashOnExceptions": true
		])
	}

	func applicationDidFinishLaunching(_ notification: Notification) {
		AppCenter.start(
			withAppSecret: "27131b3e-4b25-4a92-b0d3-7bb6883f7343",
			services: [
				Crashes.self
			]
		)

		_ = statusItemButton
		_ = desktopMonitors

		setUpEvents()
		showWelcomeScreenIfNeeded()
	}

	func openLocalWebsite(directoryURL: URL?, loadHandler: @escaping (URL) -> Void) {
		NSApp.activate(ignoringOtherApps: true)

		let panel = NSOpenPanel()
		panel.canChooseFiles = false
		panel.canChooseDirectories = true
		panel.canCreateDirectories = false
		panel.title = "Open Local Website"
		panel.message = "Choose a directory with a “index.html” file."

		// Ensure it's above the window when in "Browsing Mode".
		panel.level = .floating

		if
			let url = directoryURL,
			url.isFileURL
		{
			panel.directoryURL = url
		}

		guard let window = preferencesWindowController.window else {
			return
		}

		panel.beginSheetModal(for: window) { [weak self] in
			guard
				$0 == .OK,
				let url = panel.url
			else {
				return
			}

			guard url.appendingPathComponent("index.html", isDirectory: false).exists else {
				NSAlert.showModal(message: "Please choose a directory that contains a “index.html” file.")
				self?.openLocalWebsite(directoryURL: directoryURL, loadHandler: loadHandler)
				return
			}

			do {
				try SecurityScopedBookmarkManager.saveBookmark(for: url)
			} catch {
				NSApp.presentError(error)
				return
			}

			loadHandler(url)
		}
	}
}
