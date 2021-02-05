import Cocoa
import Defaults
import KeyboardShortcuts

extension AppDelegate {
	func setUpEvents() {
		menu.onUpdate = { [self] _ in
			updateMenu()
		}

		NSWorkspace.shared.notificationCenter
			.publisher(for: NSWorkspace.didWakeNotification)
			.sink { [self] _ in
				desktopMonitors.forEach { (_: CGDirectDisplayID, window: DesktopMonitor) in
					window.loadUserURL()
				}
			}
			.store(in: &cancellables)

		Defaults.observe(.isBrowsingMode) { [self] change in
			desktopMonitors.forEach { (_: CGDirectDisplayID, window: DesktopMonitor) in
				window.isBrowsingMode = change.newValue
			}
		}
		  .tieToLifetime(of: self)

		Defaults.observe(.displays) { [self] change in
			change.newValue.forEach { (key: CGDirectDisplayID, display: Display) in
				if display.isEnabled {
					if desktopMonitors[key] == nil {
						desktopMonitors[key] = DesktopMonitor(display: display)
						desktopMonitors[key]?.isEnabled = true
					}
				} else {
					desktopMonitors[key]?.isEnabled = false
					desktopMonitors[key] = nil
				}
				let oldDisplay = change.oldValue[key]

				guard let monitor = desktopMonitors[key] else {
					return
				}

				if display.url != oldDisplay?.url {
					monitor.resetTimer()
					monitor.loadUserURL()
				}

				if display.opacity != oldDisplay?.opacity {
					monitor.desktopWindow.alphaValue = monitor.isBrowsingMode ? 1 : CGFloat(display.opacity)
				}

				if display.reloadInterval != oldDisplay?.reloadInterval {
					monitor.resetTimer()
				}

				if display.invertColors != oldDisplay?.invertColors || display.customCSS != oldDisplay?.customCSS {
					monitor.recreateWebViewAndReload()
				}

				if display.showOnAllSpaces != oldDisplay?.showOnAllSpaces {
					monitor.desktopWindow.collectionBehavior.toggleExistence(.canJoinAllSpaces, shouldExist: display.showOnAllSpaces)
				}
			}
		}
		  .tieToLifetime(of: self)

		AppDelegate.shared.powerSourceWatcher?.onChange = { [self] _ in
			guard Defaults[.deactivateOnBattery] else {
				return
			}

			desktopMonitors.forEach { (_: CGDirectDisplayID, window: DesktopMonitor) in
				window.setEnabledStatus()
			}
		}

		KeyboardShortcuts.onKeyUp(for: .toggleBrowsingMode) {
			Defaults[.isBrowsingMode].toggle()
		}

		KeyboardShortcuts.onKeyUp(for: .reload) { [self] in
			desktopMonitors.forEach { (_: CGDirectDisplayID, window: DesktopMonitor) in
				window.loadUserURL()
			}
		}

//		webViewController.onLoaded = { [self] error in
//			// webViewError = error
//
//			guard error == nil else {
//				return
//			}
//
//			// Set the persisted zoom level.
//			let zoomLevel = webViewController.webView.zoomLevelWrapper
//			if zoomLevel != 1 {
//				webViewController.webView.zoomLevelWrapper = zoomLevel
//			}
//
//			if let url = Defaults[.url] {
//				let title = webViewController.webView.title.map { "\($0)\n" } ?? ""
//				let urlString = url.isFileURL ? url.lastPathComponent : url.absoluteString
//				statusItemButton.toolTip = "\(title)\(urlString)"
//			} else {
//				statusItemButton.toolTip = ""
//			}
//		}
	}
}
