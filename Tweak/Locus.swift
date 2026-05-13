import CydiaSubstrate
import UIKit

private struct SpringBoardHook {
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
	NSLog("[Locus] Initializing tweak")

	TweakPreferences.shared.loadPreferences()
	let preferences = TweakPreferences.shared.preferences

	if preferences.enabledApps.isEmpty { return }

	guard let currentBundleIdentifier = Bundle.main.bundleIdentifier else { return }
	guard preferences.enabledApps.contains(currentBundleIdentifier) else { return }

	SpringBoardHook.hook()
}
