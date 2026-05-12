import Foundation
import Preferences
import libroot

class RootListController: PSListController {
	private let preferencesFilePath: String = jbRootPath(
		"/var/mobile/Library/Preferences/moe.waru.locus.preferences.plist"
	)

	private func readPreferencesDictionary() -> [String: Any] {
		(NSDictionary(contentsOfFile: preferencesFilePath) as? [String: Any]) ?? [:]
	}

	private func writePreferencesDictionary(_ preferences: [String: Any]) {
		(preferences as NSDictionary).write(toFile: preferencesFilePath, atomically: true)
	}

	override var specifiers: NSMutableArray? {
		get {
			if let specifiers = value(forKey: "_specifiers") as? NSMutableArray {
				return specifiers
			} else {
				let specifiers = loadSpecifiers(fromPlistName: "Root", target: self)
				setValue(specifiers, forKey: "_specifiers")
				return specifiers
			}
		}

		set {
			super.specifiers = newValue
		}
	}

	override func readPreferenceValue(_ specifier: PSSpecifier) -> Any? {
		guard let key = specifier.property(forKey: "key") as? String else {
			return specifier.property(forKey: "default")
		}

		let preferences = readPreferencesDictionary()
		if let value = preferences[key] {
			return value
		}

		return specifier.property(forKey: "default")
	}

	override func setPreferenceValue(_ value: Any, specifier: PSSpecifier) {
		NSLog("[Locus] Setting preference value: \(value) for specifier: \(specifier)")

		guard let key = specifier.property(forKey: "key") as? String else {
			return
		}

		var preferences = readPreferencesDictionary()
		preferences[key] = value

		writePreferencesDictionary(preferences)

		super.setPreferenceValue(value, specifier: specifier)
	}
}
