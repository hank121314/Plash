import Cocoa
import Defaults

extension AppDelegate {
//	private func addInfoMenuItem() {
//		guard var url = Defaults[.url] else {
//			return
//		}
//
//		do {
//			url = try replacePlaceholders(of: url) ?? url
//		} catch {
//			error.presentAsModal()
//			return
//		}
//
//		let maxLength = 30
//
//		if
//			let title = webViewController.webView.title,
//			!title.isEmpty
//		{
//			let menuItem = menu.addDisabled(title.truncating(to: maxLength))
//			menuItem.toolTip = title
//		}
//
//		let urlString = url.isFileURL ? url.tildePath : url.absoluteString
//
//		var newUrlString = urlString
//		if urlString.count > maxLength {
//			newUrlString = urlString.removingSchemeAndWWWFromURL
//		}
//
//		let menuItem = menu.addDisabled(newUrlString.truncating(to: maxLength))
//		menuItem.toolTip = urlString
//	}

	private func createMoreMenu() -> SSMenu {
		let menu = SSMenu()

		menu.addAboutItem()

		menu.addSeparator()

		menu.addCallbackItem("Send Feedback…") { _ in
			SSApp.openSendFeedbackPage()
		}

		menu.addSeparator()

		menu.addUrlItem(
			"Website",
			url: URL("https://sindresorhus.com/plash")
		)

		menu.addUrlItem(
			"Roadmap",
			url: URL("https://github.com/sindresorhus/Plash/issues")
		)

		menu.addUrlItem(
			"Examples",
			url: URL("https://github.com/sindresorhus/Plash/issues/1")
		)

		menu.addSeparator()

		menu.addUrlItem(
			"Rate on the App Store",
			url: URL("macappstore://apps.apple.com/app/id1494023538?action=write-review")
		)

		menu.addMoreAppsItem()

		menu.addSeparator()

		menu.addUrlItem(
			"Donate",
			url: URL("https://sindresorhus.com/donate")
		)

		return menu
	}

	func updateMenu() {
		menu.removeAllItems()

//		if isEnabled {
//			if let error = webViewError {
//				menu.addDisabled("Error: \(error.localizedDescription)".wrapped(atLength: 36).attributedString)
//				menu.addSeparator()
//			}
//
//			addInfoMenuItem()
//		} else {
//			menu.addDisabled("Deactivated While on Battery")
//		}

		menu.addSeparator()

		menu.addSeparator()

//		menu.addCallbackItem(
//			"Browsing Mode",
//			key: "b",
//			isEnabled: false && Defaults[.url] != nil,
//			isChecked: false
//		) { _ in
//			SSApp.runOnce(identifier: "activatedBrowsingMode") {
//				DispatchQueue.main.async {
//					NSAlert.showModal(
//						message: "Browsing Mode lets you temporarily interact with the website. For example, to log into an account or scroll to a specific position on the website.",
//						informativeText: "If you don't currently see the website, you might need to hide some windows to reveal the desktop."
//					)
//				}
//			}
//		}

		menu.addSeparator()

		menu.addCallbackItem("Preferences…", key: ",") { [weak self] _ in
			self?.preferencesWindowController.show()
		}

		let moreMenuItem = menu.addItem("More")
		moreMenuItem.submenu = createMoreMenu()

		menu.addSeparator()

		menu.addQuitItem()
	}
}
