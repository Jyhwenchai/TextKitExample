//
//  TextEditorViewController.swift
//  TextKit
//
//  Created by 蔡志文 on 2020/8/3.
//

import UIKit

class TextEditorViewController: UIViewController {

    lazy var textView: UITextView = {
        let textView = UITextView(frame: CGRect(x: 20, y: 120, width: view.bounds.width - 40, height: 120), textContainer: textContainer)
        textView.backgroundColor = UIColor.lightGray
        return textView
    }()
    
    let textStorage = EditorTextStorage()
    let textContainer = NSTextContainer()
    let layoutManager = NSLayoutManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
    
        view.addSubview(textView)
        textStorage.replaceCharacters(in: NSRange(), with: "波浪线引起来的字符都会被~变为蓝色~，对，是这样的")
        
        let button = UIButton()
        button.setTitle("calculate text size", for: .normal)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        button.sizeToFit()
        button.center = view.center
        view.addSubview(button)
    }

    // text size
    @objc func buttonAction() {
        let size = layoutManager.usedRect(for: textContainer).size
        print(size)
    }
}
