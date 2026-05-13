import Foundation
import Preferences
import UIKit
import roothide

@_silgen_name("BKSTerminateApplicationForReasonAndReportWithDescription")
private func BKSTerminateApplicationForReasonAndReportWithDescription(
	_ bundleID: NSString, _ reasonID: Int32, _ report: Bool, _ description: NSString?
)

class RootListController: PSListController {
	private let preferencesFilePath: String = jbroot(
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

	@objc func respring() {
		let alert = UIAlertController(
			title: "Apply Changes",
			message: "This will restart all selected apps. Continue?",
			preferredStyle: .alert
		)

		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		alert.addAction(
			UIAlertAction(title: "Apply", style: .destructive) { [weak self] _ in
				guard let self else { return }

				let preferences = self.readPreferencesDictionary()
				let enabledApps = preferences["enabledApps"] as? [String] ?? []
				if enabledApps.isEmpty {
					NSLog("[Locus] Apply tapped with no enabled apps")
					return
				}

				for bundleID in enabledApps {
					BKSTerminateApplicationForReasonAndReportWithDescription(
						bundleID as NSString,
						5,
						false,
						"Locus Apply Settings" as NSString
					)
					NSLog("[Locus] Requested termination via BackBoardServices for \(bundleID)")
				}

				NSLog(
					"[Locus] Apply complete, restarted: \(enabledApps.count), failed: 0"
				)
			}
		)

		present(alert, animated: true)
	}
}
