//
//  AppModel.swift
//  GitPage
//
//  Created by Kwanghoon Choi on 2018. 3. 13..
//  Copyright © 2018년 allwithswift. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct AppModel {
	
	weak var application: UIApplication?
	
	init(_ application: UIApplication = UIApplication.shared) {
		self.application = application
	}
	
	func launch(_ options: [UIApplicationLaunchOptionsKey: Any]? = [:]) -> Bool {
		print(#function)
		print(options ?? [:])
		return true
	}
	
	func open(url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		print(#function)
		print(options)
		return true
	}
	
}
