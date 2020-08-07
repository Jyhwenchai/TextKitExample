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
        let string = "hello, world\ndidadia,aaa" as NSString
        let range = NSRange(location: 0, length: 6)
        
        let lineRange = string.lineRange(for: range)
        print(lineRange)

    }


}

