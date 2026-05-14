import CydiaSubstrate
import UIKit

private struct SBHomeScreenViewControllerHook {
	static var origIMP: IMP?

	static func hook() {
		guard let targetClass = objc_getClass("SBHomeScreenViewController") as? AnyClass else {
			return
		}

		typealias HookType = @convention(c) (SBHomeScreenViewController, Selector) -> Void

		let hook: HookType = { target, selector in
			let orig = unsafeBitCast(Self.origIMP, to: HookType.self)
			orig(target, selector)

			NSLog("[Locus] SBHomeScreenViewController did load")

			guard let viewController = target as? UIViewController else { return }
			NSLog("[Locus] ViewController: \(viewController)")
		}

		MSHookMessageEx(
			targetClass, #selector(SBHomeScreenViewController.viewDidLoad),
			unsafeBitCast(hook, to: IMP.self), &origIMP)
	}
}

@_cdecl("swift_init")
func tweakInit() {
	NSLog("[Locus] Initializing Tweak")

	SBHomeScreenViewControllerHook.hook()
}
