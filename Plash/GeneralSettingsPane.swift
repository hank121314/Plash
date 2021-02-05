import SwiftUI
import Preferences

let GeneralSettingsPane:() -> PreferencePane = {
	let pane = Preferences.Pane(
		identifier: .general,
		title: "General",
		toolbarIcon: NSImage(named: NSImage.preferencesGeneralName)!
	) {
		GeneralSettingsView()
	}

	return Preferences.PaneHostingController(pane: pane)
}
