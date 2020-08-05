//
//  MarkDownViewController.swift
//  TextKit
//
//  Created by 蔡志文 on 2020/8/5.
//

import UIKit

extension MarkdownStorage.Style {
    static var segmentItemNames: [String] {
        return ["Normal", "Bold", "Italic", "Underline", "Strike"]
    }
}

class MarkdownViewController: UIViewController {

    private var styleItems: [MarkdownStyleBar.Item] = [
        MarkdownStyleBar.Item(UIImage(systemName: "bold")!),
        MarkdownStyleBar.Item(UIImage(systemName: "italic")!),
        MarkdownStyleBar.Item(UIImage(systemName: "underline")!),
        MarkdownStyleBar.Item(UIImage(systemName: "strikethrough")!)
    ]
    
    lazy var markdonwStyleBar: MarkdownStyleBar = {
        let bar = MarkdownStyleBar(styleItems)
        bar.isMultipleSelection = true
        bar.layer.cornerRadius = 5.0
        bar.backgroundColor = UIColor.systemGray5
        return bar
    }()
    
    
    lazy var textView: UITextView = {
        let textView = UITextView(frame: CGRect(x: 0, y: 88, width: view.bounds.width, height: 200), textContainer: textContainer)
        textView.backgroundColor = UIColor.systemGray5
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return textView
    }()
    
    let layouManager = NSLayoutManager()
    let textStorage: MarkdownStorage = MarkdownStorage()
    let textContainer = NSTextContainer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textStorage.addLayoutManager(layouManager)
        layouManager.addTextContainer(textContainer)
        
        view.addSubview(textView)
        
        markdonwStyleBar.frame = CGRect(x: 10, y: 320, width: view.bounds.width - 20, height: 45)
        markdonwStyleBar.selectionHandler = { [unowned self] indexes in
            textStorage.selectedStyles = convertStyles(from: indexes)
            textStorage.selectedRange = textView.selectedRange
            textStorage.update()
        }
        view.addSubview(markdonwStyleBar)
    }
    
}


extension MarkdownViewController {
    func convertStyles(from indexes: [Int]) -> [MarkdownStorage.Style] {
        var styles = indexes.map { MarkdownStorage.Style(rawValue: 1 << $0) }
        if styles.contains(.bold)
            && styles.contains(.italic) {
            let boldIndex = styles.firstIndex { $0 == .bold }
            styles.remove(at: boldIndex!)
            let italicIndex = styles.firstIndex { $0 == .italic }
            styles.remove(at: italicIndex!)
            styles.append([.bold, .italic])
        }
        return styles
    }
}
