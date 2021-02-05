import SwiftUI
import LaunchAtLogin
import Defaults
import KeyboardShortcuts
import Preferences

private struct DeactivateOnBatterySetting: View {
	@Default(.deactivateOnBattery) private var deactivateOnBattery

	var body: some View {
		Toggle(
			"Deactivate While on Battery",
			isOn: $deactivateOnBattery
		)
	}
}

private struct KeyboardShortcutsSection: View {
	private let maxWidth: CGFloat = 160

	var body: some View {
		VStack {
			HStack {
				Text("Toggle “Browsing Mode”:")
					.frame(width: maxWidth, alignment: .trailing)
				KeyboardShortcuts.Recorder(for: .toggleBrowsingMode)
			}
			HStack {
				Text("Reload:")
					.frame(width: maxWidth, alignment: .trailing)
				KeyboardShortcuts.Recorder(for: .reload)
			}
		}
	}
}

struct GeneralSettingsView: View {
	var body: some View {
		Preferences.Container(contentWidth: 380) {
			Preferences.Section(title: "") {
			  Form {
				  VStack {
					  Section {
						  VStack(alignment: .leading) {
							  LaunchAtLogin.Toggle()
							  DeactivateOnBatterySetting()
							  KeyboardShortcutsSection()
						  }
					  }
				  }
			  }
			}
		}
	}
}

struct GeneralSettingsView_Previews: PreviewProvider {
	static var previews: some View {
		GeneralSettingsView()
	}
}
