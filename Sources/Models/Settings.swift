import Foundation

/// Enum to represent each developer for the GitHub cell
enum Developer: String {
	case luki = "Luki120"
	case cookies = "Cookie"

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
enum App: String {
	case areesha = "Areesha"
	case aurora = "Aurora"

	var appName: String {
		switch self {
			case .areesha, .aurora: return rawValue
		}
	}

	var appDescription: String {
		switch self {
			case .areesha: return "Keep track of your favorite TV shows"
			case .aurora: return "Vanilla password manager"
		}
	}

	var appURL: URL? {
		switch self {
			case .areesha: return URL(string: "https://github.com/Luki120/Areesha")
			case .aurora: return URL(string: "https://luki120.github.io/depictions/web/?p=me.luki.aurora")
		}
	}

}

/// Enum to represent each funding platform for the funding cell
enum FundingPlatform: String {
	case kofi = "Ko-fi"
	case paypal = "PayPal"

	var name: String {
		switch self {
			case .kofi, .paypal: return rawValue
		}
	}

	var url: URL? {
		switch self {
			case .kofi: return URL(string: "https://ko-fi.com/Luki120")
			case .paypal: return URL(string: "https://paypal.me/Luki120")
		}
	}
} 
