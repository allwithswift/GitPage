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
		URLSession.shared.dataTask(with: URL(string: "https://github.com/login/oauth/authorize?client_id=0e9d37c65fbee1890a0e6eacad205148e3025dc7&redirect_uri=gitpage://authorize&scope=user repo&state=123456")!) { (data, response, error) in
			print(#function)
			print(data)
			print(response)
			print(error)
		}.resume()
	}
	
}

