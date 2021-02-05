import SwiftUI
import LaunchAtLogin
import Defaults
import KeyboardShortcuts
import Preferences

private struct ToggleMonitor: View {
	@Binding var isEnabled: Bool

	var body: some View {
		HStack {
			Toggle(isOn: $isEnabled) {
			  Text("Enable on this monitor")
			}
		}
	}
}

private struct OpacitySetting: View {
	@Binding var opacity: Double

	var body: some View {
		HStack {
			Text("Opacity:")
			Slider(value: $opacity, in: 0.1...1, step: 0.1)
		}
	}
}

private struct ReloadIntervalSetting: View {
	private static let defaultReloadInterval = 60.0
	private static let minimumReloadInterval = 0.1

	private static let reloadIntervalFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.formattingContext = .standalone
		formatter.locale = Locale.autoupdatingCurrent
		formatter.numberStyle = .decimal
		formatter.minimum = NSNumber(value: minimumReloadInterval)
		formatter.minimumFractionDigits = 1
		formatter.maximumFractionDigits = 1
		formatter.isLenient = true
		return formatter
	}()

	@Binding var reloadInterval: Double?

	private var reloadIntervalInMinutes: Binding<Double> {
		$reloadInterval.withDefaultValue(Self.defaultReloadInterval).secondsToMinutes
	}

	private var hasInterval: Binding<Bool> {
		$reloadInterval.isNotNil(trueSetValue: Self.defaultReloadInterval)
	}

	var body: some View {
		HStack {
			Text("Reload Interval:")
			Toggle(isOn: hasInterval) {
				Stepper(
					value: reloadIntervalInMinutes,
					in: Self.minimumReloadInterval...(.greatestFiniteMagnitude),
					step: 1
				) {
					TextField(
						"",
						value: reloadIntervalInMinutes,
						formatter: Self.reloadIntervalFormatter
					)
						.frame(width: 70)
				}
					.disabled(!hasInterval.wrappedValue)
				Text("minutes")
			}
				.fixedSize()
		}
	}
}

private struct ShowOnAllSpacesSetting: View {
	@Binding var showOnAllSpaces: Bool

	var body: some View {
		Toggle(
			"Show on All Spaces",
			isOn: $showOnAllSpaces
		)
			.help2("When disabled, the website will be shown on the space that was active when Plash launched.")
	}
}

private struct InvertColorsSetting: View {
	@Binding var invertColors: Bool

	var body: some View {
		VStack {
			Toggle(
				"Invert Website Colors",
				isOn: $invertColors
			)
				.help2("This creates a fake dark mode.")
		}
	}
}

private struct CustomCSSSetting: View {
	@Binding var customCSS: String

	var body: some View {
		VStack {
			Text("Custom CSS:")
			ScrollableTextView(
				text: $customCSS,
				font: .monospacedSystemFont(ofSize: 11, weight: .regular)
			)
				.frame(height: 100)
		}
	}
}

private struct ClearWebsiteDataSetting: View {
	@Binding var hasCleared: Bool
	@Binding var selectedId: CGDirectDisplayID

	var body: some View {
		Button("Clear Website Data") {
			hasCleared = true
			guard let webView = AppDelegate.shared.desktopMonitors[selectedId]?.webViewController.webView else {
				return
			}
			webView.clearWebsiteData(completion: nil)
		}
			.disabled(hasCleared)
			.help2("Clears all cookies, local storage, caches, etc.")
			// TODO: Mark it as destructive when SwiftUI supports that.
	}
}

private struct DisplaySettingsView: View {
	@Binding var display: Display
	@Binding var hasCleared: Bool
	@Binding var urlString: String

	var body: some View {
		VStack {
			ToggleMonitor(isEnabled: $display.isEnabled)
			OpenURLView(urlString: $urlString) { url in
				display.url = url
			}
			Divider()
			  .padding(.vertical)
			Section {
				HStack(alignment: .center, spacing: 60) {
					ShowOnAllSpacesSetting(showOnAllSpaces: $display.showOnAllSpaces)
					InvertColorsSetting(invertColors: $display.invertColors)
				}
			}
			Divider()
				.padding(.vertical)
			Section {
				OpacitySetting(opacity: $display.opacity)
			}
			Divider()
				.padding(.vertical)
			Section {
				ReloadIntervalSetting(reloadInterval: $display.reloadInterval)
			}
			Section {
				Divider()
					.padding(.vertical)
				CustomCSSSetting(customCSS: $display.customCSS)
				Divider()
					.padding(.vertical)
				ClearWebsiteDataSetting(hasCleared: $hasCleared, selectedId: $display.id)
			}
		}
	}
}

struct MonitorSettingsView: View {
	@Default(.displays) private var displays
	@ObservedObject private var monitorWrapper = Monitors.observable
	@State private var selectedId: CGDirectDisplayID?
	@State private var urlString = ""
	@State private var hasCleared = false

	var body: some View {
		let display = Binding<Display>(get: {
			if selectedId == nil {
				return Display(id: CGMainDisplayID())
			}

			if let display = displays[selectedId!] {
				return display
			}

			return Display(id: selectedId!)
		}, set: {
			displays[selectedId!] = $0
		})

		Preferences.Container(contentWidth: 730) {
			Preferences.Section(title: "") {
			  Form {
				HStack(alignment: .top) {
					VStack {
					  Text("Available Monitor").frame(maxWidth: .infinity, alignment: .leading)
						List(
							monitorWrapper.wrappedValue.all,
							id: \.id,
							selection: $selectedId.onChange { _ in
								hasCleared = false

								guard
									let url = display.wrappedValue.url
								else {
									return
								}

								urlString = url.absoluteString.removingPercentEncoding ?? url.absoluteString
							}
						) { display in
							HStack {
								Text(display.localizedName)
							}
						}
						.listStyle(SidebarListStyle())
					}
					  .frame(width: 200, height: 500)
					if !selectedId.isNil {
						DisplaySettingsView(display: display, hasCleared: $hasCleared, urlString: $urlString)
					} else {
					  Text("Please select a monitor")
						.foregroundColor(.gray)
						.font(.system(size: 20))
						.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
					}
				}
			  }
			}
		}
	}
}

struct MonitorSettingsView_Previews: PreviewProvider {
	static var previews: some View {
		MonitorSettingsView()
	}
}
