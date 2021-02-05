import SwiftUI
import Defaults

struct OpenURLView: View {
	@Binding var urlString: String

	private var normalizedUrlString: String {
		URL(humanString: urlString)?.absoluteString ?? urlString
	}

	let loadHandler: (URL) -> Void

	var body: some View {
		VStack(alignment: .trailing) {
			if SSApp.isFirstLaunch {
				HStack {
					HStack(spacing: 3) {
						Text("You could, for example,")
						Button("show the time.") {
							urlString = "https://time.pablopunk.com/?seconds&fg=white&bg=transparent"
						}
							.buttonStyle(LinkButtonStyle())
					}
					Spacer()
					Button("More ideas") {
						"https://github.com/sindresorhus/Plash/issues/1".openUrl()
					}
						.buttonStyle(LinkButtonStyle())
				}
					.box()
			}
			HStack {
			  TextField(
				  "sindresorhus.com",
				  // `removingNewlines` is a workaround for a SwiftUI bug where it doesn't respect the line limit when pasting in multiple lines.
				  // TODO: Report to Apple. Still an issue on macOS 11.
				  text: $urlString.setMap(\.removingNewlines)
			  )
				  .lineLimit(1)
				  .frame(minWidth: 350)
				  .padding(.vertical)
			  NativeButton("Open Local Website") {
				AppDelegate.shared.openLocalWebsite(directoryURL: URL(string: normalizedUrlString)) { url in
					loadHandler(url)
				}
			  }
			}
			// TODO: Use `Button` when targeting macOS 11.
			NativeButton("Open", keyEquivalent: .return) {
				guard let url = URL(string: normalizedUrlString) else {
					return
				}

				loadHandler(url)
			}
			.disabled(!URL.isValid(string: normalizedUrlString))
				.frame(maxWidth: .infinity)
		}
			.padding()
	}
}

struct OpenURLView_Previews: PreviewProvider {
	static var previews: some View {
		OpenURLView(urlString: .constant("about:blank")) { _ in }
	}
}
