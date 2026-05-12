import CydiaSubstrate
import UIKit

@objc
private protocol SpringBoard {
	@objc func applicationDidFinishLaunching(_ launching: SpringBoard)
}

private struct Hooks {
	static var origIMP: IMP?

	static func hook() {
		guard let targetClass = objc_getClass("SpringBoard") as? AnyClass else { return }

		typealias HookType = @convention(c) (SpringBoard, Selector, SpringBoard) -> Void

		let hook: HookType = { target, selector, launching in
			let orig = unsafeBitCast(Self.origIMP, to: HookType.self)
			orig(target, selector, launching)

			NSLog("[Locus] SpringBoard did finish launching")
		}

		MSHookMessageEx(
			targetClass, #selector(SpringBoard.applicationDidFinishLaunching(_:)),
			unsafeBitCast(hook, to: IMP.self), &origIMP)
	}
}

@_cdecl("swift_init")
func tweakInit() {
	TweakPreferences.shared.loadPreferences()
	let preferences = TweakPreferences.shared.preferences

	NSLog("[Locus] Loaded preferences: \(preferences)")

	if preferences.enabledApps.isEmpty {
		NSLog("[Locus] No enabled apps, skipping hooks")
		return
	}

	guard let currentBundleIdentifier = Bundle.main.bundleIdentifier else { return }
	guard preferences.enabledApps.contains(currentBundleIdentifier) else {
		NSLog(
			"[Locus] App \(currentBundleIdentifier) is not enabled, skipping hooks"
		)
		return
	}

	NSLog("[Locus] Enabling hooks for app: \(currentBundleIdentifier)")

	Hooks.hook()
}
