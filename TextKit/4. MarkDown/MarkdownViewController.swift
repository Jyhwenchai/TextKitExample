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

    var lastSelectedRange = NSRange()

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
        textView.delegate = self
        textView.isUserInteractionEnabled = true
        return textView
    }()
    
    let layouManager = NSLayoutManager()
    let textStorage: MarkdownStorage = MarkdownStorage()
    let textContainer = NSTextContainer()
    
    var tapLocationHasText = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textStorage.addLayoutManager(layouManager)
        layouManager.addTextContainer(textContainer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textViewTapGesture(sender:)))
        tapGesture.delegate = self
        textView.addGestureRecognizer(tapGesture)
        view.addSubview(textView)
        
        markdonwStyleBar.frame = CGRect(x: 10, y: 320, width: view.bounds.width - 20, height: 45)
        markdonwStyleBar.selectionHandler = { [unowned self] indexes in
            textStorage.selectedStyles = convertStyles(from: indexes)
            textStorage.selectedRange = textView.selectedRange
            textStorage.update()
        }
        view.addSubview(markdonwStyleBar)
    }
    
    
    @objc func textViewTapGesture(sender: UITapGestureRecognizer) {
        let sentTextView = sender.view as? UITextView
        if let textView = sentTextView {
            
        
            let layoutManager = textView.layoutManager
            // location of tap in myTextView coordinate
            var location = sender.location(in: sentTextView)
            location.x -= textView.textContainerInset.left
            location.y -= textView.textContainerInset.top
   
            // 根据点击位置获取glyph(字形)的索引
            let glyphIndex = layoutManager.glyphIndex(for: location, in: textContainer)
            // 获取glyph所在的区域
            let glyphRect = layoutManager.boundingRect(forGlyphRange: NSRange(location: glyphIndex, length: 1), in: textContainer)
            tapLocationHasText = glyphRect.contains(location)
            if !glyphRect.contains(location) {
                lastSelectedRange = NSRange(location: textView.text.count, length: 0)
                textView.selectedRange = lastSelectedRange
            }
        }
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
        } else if styles.count == 0 {
            styles.append(.normal)
        }
        return styles
    }
}

extension MarkdownViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        
//        if !tapLocationHasText {
//            return
//        }
        
        if lastSelectedRange.length > 0
            && textView.selectedRange.length == 0
            && textView.selectedRange.location == textView.text.count {
            lastSelectedRange = NSRange(location: textView.selectedRange.location - 1, length: 1)
            DispatchQueue.main.async { [self] in
                textView.selectedRange = lastSelectedRange
            }
            return
        }
        
        lastSelectedRange = textView.selectedRange
        var separatorAttributeStringCount = 0
        var copyAttributes: [NSAttributedString.Key: Any]?
        textStorage.enumerateAttributes(in: textView.selectedRange, options: .longestEffectiveRangeNotRequired) { (attributes, range, pointer) in
            copyAttributes = attributes
            separatorAttributeStringCount += 1
        }
        
        guard let attributes = copyAttributes else { return }
        var styles: [MarkdownStorage.Style] = []
        
        if separatorAttributeStringCount == 0 {
            return
        }
        
        if separatorAttributeStringCount == 1 {
            
            if let font = attributes[.font] as? UIFont {
                styles.append(font.associateStyle)
            }
          
            if let _ = attributes[.underlineStyle] {
                styles.append(.underline)
            }
            
            if let _ = attributes[.strikethroughStyle] {
                styles.append(.strike)
            }
        }

        textStorage.selectedStyles = styles
        updateStyleBar(with: textStorage.selectedStyles)
//        0000 0000 0000 0000 0000 0000 0000 0000
//        if let range = singleRange, separatorAttributeStringCount == 1 {
//            for key in textStorage.seperatorStringStyleDictionary.keys where key.contains(range.location + range.length - 1) {
//                if let styles = textStorage.seperatorStringStyleDictionary[key] {
//                    textStorage.selectedStyles = styles
//                    updateStyleBar(with: textStorage.selectedStyles)
//                }
//            }
//        } else if (separatorAttributeStringCount > 1) {
//            textStorage.selectedStyles = [.normal]
//            updateStyleBar(with: textStorage.selectedStyles)
//        }
    }
    
    
    func updateStyleBar(with styles: [MarkdownStorage.Style]) {
        markdonwStyleBar.resetStyleToNoneSelect()
        styles.forEach {
            if $0 == [.bold, .italic] {
                [0, 1].forEach { markdonwStyleBar.updateStyleItem(at: $0, selected: true) }
            } else {
                markdonwStyleBar.updateStyleItem(at: $0.traitsIndex, selected: true)
            }
        }
    }
}

extension UIFont {
    
    var associateStyle: MarkdownStorage.Style {
        
        let boldTrait = UIFontDescriptor.SymbolicTraits.traitBold
        let italicTrait = UIFontDescriptor.SymbolicTraits.traitItalic
        let boldAndItalicTrait: UIFontDescriptor.SymbolicTraits = [
            UIFontDescriptor.SymbolicTraits.traitItalic,
            UIFontDescriptor.SymbolicTraits.traitBold
        ]
        
        let fontTraitValue = (fontDescriptor.symbolicTraits.rawValue << 16) >> 16
        
        var style: MarkdownStorage.Style = .normal
        
        if (fontTraitValue & boldAndItalicTrait.rawValue) == boldAndItalicTrait.rawValue {
            style = [.bold, .italic]
        } else if (fontTraitValue & boldTrait.rawValue) == boldTrait.rawValue {
            style = .bold
        } else if (fontTraitValue & italicTrait.rawValue) == italicTrait.rawValue {
            style = .italic
        }
        
        return style
    }
    
}

extension MarkdownStorage.Style {
    var traitsIndex: Int {
        switch self {
        case .bold: return 0
        case .italic: return 1
        case .underline: return 2
        case .strike: return 3
        default: return -1
        }
    }
    
}

extension MarkdownViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
