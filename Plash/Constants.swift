import Cocoa
import Defaults
import KeyboardShortcuts
import Preferences

struct Constants {
	static let menuBarIcon = NSImage(named: "MenuBarIcon")!
}

extension Defaults.Keys {
	static let displays = Key<[CGDirectDisplayID: Display]>("displays", default: [CGMainDisplayID(): Display(id: CGMainDisplayID())])
	static let isBrowsingMode = Key<Bool>("isBrowsingMode", default: false)
	static let deactivateOnBattery = Key<Bool>("deactivateOnBattery", default: false)
}

extension Preferences.PaneIdentifier {
	static let general = Self("general")
	static let monitor = Self("monitor")
}

extension KeyboardShortcuts.Name {
	static let toggleBrowsingMode = Self("toggleBrowsingMode")
	static let reload = Self("reload")
}
