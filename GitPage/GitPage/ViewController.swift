//
//  ViewController.swift
//  GitPage
//
//  Created by Kwanghoon Choi on 2018. 3. 2..
//  Copyright © 2018년 allwithswift. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func clickLogin(_ sender: Any) {
		var urlComps = URLComponents(string: "https://github.com/login/oauth/authorize")
		let queryItems: [URLQueryItem] = [URLQueryItem.init(name: "client_id", value: "0e9d37c65fbee1890a0e6eacad205148e3025dc7"),
																			URLQueryItem.init(name: "redirect_uri", value: "gitpage://authorize"),
																			URLQueryItem.init(name: "scope", value: "user repo"),
																			URLQueryItem.init(name: "state", value: "123456")]
		urlComps?.queryItems = queryItems
		URLSession.shared.dataTask(with: urlComps!.url!) { (data, response, error) in
			print(#function)
			print(String.init(data: data ?? Data(), encoding: .utf8) ?? "null data")
			print(error?.localizedDescription ?? "null error")
		}.resume()
	}

}
