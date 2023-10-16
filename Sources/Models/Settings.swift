import Foundation

/// Enum to represent each developer for the GitHub cell
@frozen enum Developer: String {
	case luki = "Luki120"
	case cookies = "Cookies"

	static let lukiIcon = "https://avatars.githubusercontent.com/u/74214115?v=4"
	static let cookiesIcon = "https://avatars.githubusercontent.com/u/98801093?v=4"

	var devName: String {
		switch self {
			case .luki, .cookies: return rawValue
		}
	}

	var targetURL: URL? {
		switch self {
			case .luki: return URL(string: "https://github.com/Luki120")
			case .cookies: return URL(string: "https://github.com/6007135")
		}
	}

}

/// Enum to represent each app for the app cell
@frozen enum App: String {
	case aurora = "Aurora"
	case cora = "Cora"

	var appName: String {
		switch self {
			case .aurora, .cora: return rawValue
		}
	}

	var appDescription: String {
		switch self {
			case .aurora: return "Vanilla password manager"
			case .cora: return "See your device's uptime in less clicks"
		}
	}

	var appURL: URL? {
		switch self {
			case .aurora: return URL(string: "https://luki120.github.io/depictions/web/?p=me.luki.aurora")
			case .cora: return URL(string: "https://luki120.github.io/depictions/web/?p=me.luki.cora")
		}
	}

}
