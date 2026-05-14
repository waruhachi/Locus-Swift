import Foundation
import libroot

struct Preferences: Codable {
	var enabledApps: [String] = []

	enum CodingKeys: String, CodingKey {
		case enabledApps
	}

	init() {}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		enabledApps =
			try container.decodeIfPresent([String].self, forKey: .enabledApps)
			?? []
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(enabledApps, forKey: .enabledApps)
	}
}

public final class TweakPreferences {
	static let shared = TweakPreferences()

	private(set) var preferences: Preferences = .init()

	private let preferencesFilePath: String = jbRootPath(
		"/var/mobile/Library/Preferences/moe.waru.locus.preferences.plist"
	)

	func loadPreferences() {
		do {
			let data = try Data(contentsOf: URL(fileURLWithPath: preferencesFilePath))
			preferences = try PropertyListDecoder().decode(Preferences.self, from: data)
		} catch {
			NSLog("[Locus] Failed to load preferences: \(error)")
		}
	}
}
