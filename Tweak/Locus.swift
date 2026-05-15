import CydiaSubstrate
import SwiftUI
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

			let hosting = UIHostingController(rootView: TestView())
			hosting.view.translatesAutoresizingMaskIntoConstraints = false
			hosting.view.backgroundColor = .clear

			viewController.addChild(hosting)
			viewController.view.addSubview(hosting.view)
			hosting.didMove(toParent: viewController)

			NSLayoutConstraint.activate([
				hosting.view.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
				hosting.view.topAnchor.constraint(equalTo: viewController.view.topAnchor),
				hosting.view.widthAnchor.constraint(equalToConstant: 40),
				hosting.view.heightAnchor.constraint(equalToConstant: 30),
			])
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
