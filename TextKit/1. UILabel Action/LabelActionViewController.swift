//
//  LabelActionViewController.swift
//  TextKit
//
//  Created by 蔡志文 on 2020/8/3.
//

import UIKit

class LabelActionViewController: UIViewController {

    @IBOutlet weak var infoLabel: ActionLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let attributedString1 = NSAttributedString(string: "这是一份", attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.systemBlue
        ])
        
        infoLabel.append(string: attributedString1) { attributedString in
            print(attributedString)
        }
        
        let attributedString2 = NSAttributedString(string: "补充", attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.red
        ])
            
        infoLabel.append(string: attributedString2) { attributedString in
            print(attributedString)
        }
        
        let attributedString3 = NSAttributedString(string: "协议", attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.systemBlue
        ])
        
        infoLabel.append(string: attributedString3) { attributedString in
            print(attributedString)
        }
    }
    

}
