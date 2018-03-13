//
//  UIViewController+Tree.swift
//  GitPage
//
//  Created by Kwanghoon Choi on 2018. 3. 13..
//  Copyright © 2018년 allwithswift. All rights reserved.
//

import UIKit

extension UIViewController {
	
	enum PresentType: Equatable {
		static func == (lhs: UIViewController.PresentType, rhs: UIViewController.PresentType) -> Bool {
			return String.init(describing: lhs) == String.init(describing: rhs)
		}
		
		case present(UIViewController)
		case push(UIViewController)
		case noChange
	}
	
	enum DismissType: Equatable {
		static func == (lhs: UIViewController.DismissType, rhs: UIViewController.DismissType) -> Bool {
			return String.init(describing: lhs) == String.init(describing: rhs)
		}
		
		case dismiss
		case pop
		case noChange
	}
	
	typealias PresentCompletion = (PresentType) -> Void
	typealias DismissCompletion = (DismissType) -> Void
	typealias BoolCompletion = (Bool) -> Void
	
	// MARK: With
	struct With {
		internal let viewController: UIViewController
		var navigation: UINavigationController {
			return self.viewController as? UINavigationController ?? self.viewController.navigationController ?? UINavigationController(rootViewController: self.viewController)
		}
	}
	
	struct Presents {
		internal var viewController: UIViewController
		var down: UIViewController? {
			return self.viewController.presentingViewController
		}
		var up: UIViewController? {
			return self.viewController.presentedViewController
		}
		var layers: [UIViewController] {
			var layers: [UIViewController] = []
			var current: UIViewController? = self.rearmost
			repeat {
				if let current = current {
					layers.append(current)
				}
				current = current?.presents.up
			} while current != nil
			return layers
		}
		/// 맨앞
		var forefront: UIViewController {
			if let up = self.up {
				return up.presents.forefront
			}
			return self.viewController.parent ?? self.viewController
		}
		/// 맨뒤
		var rearmost: UIViewController {
			if let down = self.down {
				return down.presents.rearmost
			}
			return self.viewController.parent ?? self.viewController
		}
	}
	
	/// Tree가 반환하는 모든 값은 해당 값이 없을 경우 자신을 반환한다.
	struct Tree {
		
		internal let viewController: UIViewController
		
		var first: UIViewController {
			let rearmost = viewController.presents.rearmost
			return rearmost.childViewControllers.first ?? rearmost
		}
		
		var last: UIViewController {
			let forefront = viewController.presents.forefront
			return forefront.childViewControllers.last ?? forefront
		}
		
		func contains<ViewController>(_ viewController: ViewController) -> Bool where ViewController: UIViewController {
			return self.find(of: ViewController.self, filter: { $0 == viewController }) != nil
		}
		
		func find<ViewController: UIViewController>(of type: ViewController.Type, filter: @escaping ((ViewController) -> Bool) = { (_) in true }) -> ViewController? {
			
			let cast: (UIViewController?) -> ViewController? = {
				guard let casted = $0 as? ViewController, filter(casted) else {
					return nil
				}
				return casted
			}
			
			var current: UIViewController? = self.viewController.presents.forefront
			repeat {
				if let casted = cast(current) {
					return casted
				}
				for child in current?.childViewControllers ?? [] {
					if let casted = cast(child) {
						return casted
					}
				}
				current = current?.presents.down
			} while current != nil
			return nil
		}
		
		@discardableResult
		func show(_ viewController: UIViewController, present: Bool = false, animated: Bool = true, completion: PresentCompletion? = nil) -> PresentType {
			if self.contains(viewController) {
				completion?(.noChange)
				return .noChange
			}
			let forefront = self.viewController.presents.forefront
			if present {
				forefront.present(viewController, animated: animated, completion: {
					completion?(.present(viewController))
				})
				return .present(viewController)
			}
			if viewController is UINavigationController || (forefront is UINavigationController) == false {
				forefront.present(viewController, animated: animated, completion: { completion?(.present(viewController)) })
				return .present(viewController)
			} else if let navigation = forefront as? UINavigationController {
				navigation.pushViewController(viewController, animated: animated, completion: {
					completion?(.push(viewController))
				})
				return .push(viewController)
			} else {
				completion?(.noChange)
				return .noChange
			}
		}
		
		@discardableResult
		func setLast(animated: Bool = true, completion: BoolCompletion? = nil) -> Bool {
			return pop(to: self.viewController, animated: animated, completion: { type in completion?(type != .noChange) }) != .noChange
		}
		
		/// 현자 화면 최상단 스택에 위치한 뷰가 present라면 dismiss를 실행하고, navigationController를 parent로 가진다면 pop을 실행한다.
		@discardableResult
		func pop(to viewController: UIViewController? = nil, animated: Bool = true, completion: DismissCompletion? = nil) -> DismissType {
			if let viewController = viewController {
				for layer in self.viewController.presents.layers {
					if layer == viewController, let presenting = layer.presentingViewController {
						presenting.dismiss(animated: animated, completion: {
							completion?(.dismiss)
						})
						return .dismiss
					}
					if let navigation = layer as? UINavigationController, navigation.viewControllers.contains(viewController) {
						if navigation.viewControllers.last == viewController {
							if navigation.presentedViewController != nil {
								navigation.dismiss(animated: animated, completion: {
									completion?(.dismiss)
								})
								return .dismiss
							}
						} else {
							if navigation.presentedViewController != nil {
								navigation.dismiss(animated: animated, completion: {
									navigation.popToViewController(viewController, animated: animated, completion: {
										completion?(.pop)
									})
								})
								return .pop
							}
						}
					}
				}
			} else {
				// navigationController의 viewControllers갯수가 하나 이상일 경우 pop을 호출
				if let navigation = self.last.navigationController, navigation.viewControllers.count > 1 {
					navigation.popViewController(animated: animated, completion: {
						completion?(.pop)
					})
					return .pop
				} else if let presenting =  self.last.presentingViewController {
					presenting.dismiss(animated: animated, completion: {
						completion?(.dismiss)
					})
					return .dismiss
				}
			}
			completion?(.noChange)
			return .noChange
		}
	}
	
	var with: With {
		return With(viewController: self)
	}
	
	var tree: Tree {
		return Tree(viewController: self)
	}
	
	var presents: Presents {
		return Presents(viewController: self)
	}
	
}

extension UINavigationController {
	
	func popToRootViewController(animated: Bool, completion: @escaping () -> Void) {
		self.popToRootViewController(animated: animated)
		self.animateCompletion(animated: animated, completion: completion)
	}
	
	func popViewController(animated: Bool, completion: @escaping () -> Void) {
		self.popViewController(animated: animated)
		self.animateCompletion(animated: animated, completion: completion)
	}
	
	func popToViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
		self.popToViewController(viewController, animated: animated)
		self.animateCompletion(animated: animated, completion: completion)
	}
	
	func pushViewController(_ viewController: UIViewController, animated: Bool = true, completion: @escaping () -> Void) {
		self.pushViewController(viewController, animated: animated)
		self.animateCompletion(animated: animated, completion: completion)
	}
	
	func setViewControllers(_ viewControllers: [UIViewController], animated: Bool = true, completion: @escaping () -> Void) {
		self.setViewControllers(viewControllers, animated: animated)
		self.animateCompletion(animated: animated, completion: completion)
	}
	
	private func animateCompletion(animated: Bool, completion: @escaping () -> Void) {
		guard animated, let transition = self.transitionCoordinator else {
			completion()
			return
		}
		transition.animate(alongsideTransition: nil) { (_) in
			completion()
		}
	}
}
