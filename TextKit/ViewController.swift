//
//  ViewController.swift
//  TextKit
//
//  Created by 蔡志文 on 2020/8/3.
//

import UIKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let attributedString = NSMutableAttributedString()
        attributedString.replaceCharacters(in: NSRange(), with: "hello, world")
        attributedString.replaceCharacters(in: NSRange(location: 0, length: 3), with: NSAttributedString(string: "hello, world!"))
        print(attributedString)
    }


}

