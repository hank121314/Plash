import Cocoa
import Combine
import Defaults
import KeyboardShortcuts

final class DesktopMonitor {
	let id: CGDirectDisplayID

	let display: Display

	let webViewController: WebViewController

	let desktopWindow: DesktopWindow

	var reloadTimer: Timer?

	init(display: Display) {
		self.id = display.id
		self.display = display
		let webViewController = WebViewController(id: display.id)
		self.desktopWindow = with(DesktopWindow(screen: display.screen)) {
			$0.contentView = webViewController.webView
			$0.contentView?.isHidden = true
		}
		self.webViewController = webViewController
		self.desktopWindow.isInteractive = false
	}

	var isBrowsingMode = false {
		didSet {
			webViewController.isBrowsingMode = isBrowsingMode
			desktopWindow.isInteractive = isBrowsingMode
			desktopWindow.alphaValue = isBrowsingMode ? 1 : CGFloat(display.opacity)
			resetTimer()
		}
	}

	var isEnabled = true {
		didSet {
			if isEnabled {
				loadUserURL()
				desktopWindow.makeKeyAndOrderFront(self)
			} else {
				// TODO: Properly unload the web view instead of just clearing and hiding it.
				desktopWindow.orderOut(self)
				loadURL(URL("about:blank"))
			}
		}
	}

	var webViewError: Error? {
		didSet {
			if let error = webViewError {
				// TODO: Also present the error when the user just added it from the input box as then it's also "interactive".
				if isBrowsingMode {
					NSApp.presentError(error)
				}
			}
		}
	}

	func setEnabledStatus() {
		isEnabled = !(Defaults[.deactivateOnBattery] && AppDelegate.shared.powerSourceWatcher?.powerSource.isUsingBattery == true)
	}


	func recreateWebView() {
		webViewController.recreateWebView()
		desktopWindow.contentView = webViewController.webView
	}

	func recreateWebViewAndReload() {
		recreateWebView()
		loadUserURL()
	}

	func loadUserURL() {
		loadURL(Defaults[.displays][id]?.url)
	}

	func loadURL(_ url: URL?) {
		webViewError = nil

		guard var url = url else {
			return
		}

		do {
			url = try replacePlaceholders(of: url) ?? url
		} catch {
			error.presentAsModal()
			return
		}

		// TODO: This is just a quick fix. The proper fix is to create a new web view below the existing one (with no opacity), load the URL, if it succeeds, we fade out the old one while fading in the new one. If it fails, we discard the new web view.
		if !url.isFileURL, !Reachability.isOnlineExtensive() {
			webViewError = NSError.appError("No internet connection.")
			return
		}

		// TODO: Report the bug to Apple.
		// WKWebView has a bug where it can only load a local file once. So if you load file A, load file B, and load file A again, it errors. And if you load the same file as the existing one, nothing happens. Quality engineering.
		if url.isFileURL {
			recreateWebView()
		}

		webViewController.loadURL(url)

		// TODO: Add a callback to `loadURL` when it's done loading instead.
		// TODO: Fade in the web view.
		delay(seconds: 1) { [self] in
			desktopWindow.contentView?.isHidden = false
		}
	}


	func resetTimer() {
		reloadTimer?.invalidate()
		reloadTimer = nil

		guard !isBrowsingMode else {
			return
		}

		guard let reloadInterval = display.reloadInterval else {
			return
		}

		reloadTimer = Timer.scheduledTimer(withTimeInterval: reloadInterval, repeats: true) { [self] _ in
			loadUserURL()
		}
	}

	/**
	Replaces app-specific placeholder strings in the given URL with a corresponding value.
	*/
	func replacePlaceholders(of url: URL) throws -> URL? {
		// Here we swap out `[[screenWidth]]` and `[[screenHeight]]` for their actual values.
		// We proceed only if we have an `NSScreen` to work with.
		guard let screen = desktopWindow.targetScreen?.withFallbackToMain ?? .main else {
			return nil
		}

		return try url
			.replacingPlaceholder("[[screenWidth]]", with: String(format: "%.0f", screen.visibleFrameWithoutStatusBar.width))
			.replacingPlaceholder("[[screenHeight]]", with: String(format: "%.0f", screen.visibleFrameWithoutStatusBar.height))
	}
}
