import SwiftUI
import Preferences

let MonitorSettingsPane:() -> PreferencePane = {
	let pane = Preferences.Pane(
		identifier: .monitor,
		title: "Monitor",
		toolbarIcon: NSImage(named: NSImage.computerName)!
	) {
		MonitorSettingsView()
	}

	return Preferences.PaneHostingController(pane: pane)
}
