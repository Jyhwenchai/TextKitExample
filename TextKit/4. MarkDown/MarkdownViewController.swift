//
//  MarkDownViewController.swift
//  TextKit
//
//  Created by 蔡志文 on 2020/8/5.
//

import UIKit

class MarkdownViewController: UIViewController {

    var lastSelectedRange = NSRange()
    
    var exclusionRects: [CGRect] = []
    
    let exclusionManager = ExclusionManager()
    
    
    lazy var styleBarGroupView: MarkdownStyleBarGroupView = MarkdownStyleBarGroupView(frame: CGRect(x: 10, y: 350, width: view.bounds.width - 20, height: 45))
    
    
    lazy var textView: UITextView = {
        let textView = UITextView(frame: CGRect(x: 0, y: 88, width: view.bounds.width, height: 200), textContainer: textContainer)
        textView.backgroundColor = UIColor.systemGray5
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.delegate = self
        textView.isUserInteractionEnabled = true
        textView.becomeFirstResponder()
        textView.font = textStorage.editFont
        return textView
    }()
    
    let layoutManager = NSLayoutManager()
    let textStorage: MarkdownStorage = MarkdownStorage()
    let textContainer = NSTextContainer()
    
    var tapLocationHasText = false
    
    
    @IBOutlet weak var sbTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textViewTapGesture(sender:)))
        tapGesture.delegate = self
        textView.addGestureRecognizer(tapGesture)
        view.addSubview(textView)
        view.addSubview(styleBarGroupView)
        textStorage.replaceCharacters(in: NSRange(), with: "")
        initActions()
    }
    
    func initActions() {
        styleBarGroupView.fontStyleSelectionHandler = { [unowned self] indexes in
            textStorage.selectedStyles = convertStyles(from: indexes)
            textStorage.selectedRange = textView.selectedRange
            textStorage.update()
        }
        
        styleBarGroupView.imageStyleSelectionHandler = { [self] in
            
            let image = UIImage(named: "img")!
            let width = textView.bounds.width - textView.textContainerInset.left - textView.textContainerInset.right - 10
            let scaleFactor = image.size.width / width
            let newImage = UIImage(cgImage: image.cgImage!, scale: scaleFactor, orientation: .up)
            let attachment = NSTextAttachment(image: newImage)
    
    
            let string = "\n"
            let wrapLineAttributedString = NSAttributedString(string: string)

            let mutableString = NSMutableAttributedString()
            mutableString.append(wrapLineAttributedString)
            mutableString.append(NSAttributedString(attachment: attachment))
            mutableString.append(wrapLineAttributedString)

    
            textStorage.replaceCharacters(in: textView.selectedRange, with: mutableString)
            let selectedRange = NSRange(location: textView.selectedRange.location + 3, length: 0)
            textView.selectedRange = selectedRange
 
        }
        
        styleBarGroupView.typesettingSelectionHandler = { [self] index in

           
            
            if let selectedTextRange = textView.selectedTextRange {
                
                let selectionStartRect = textView.caretRect(for: selectedTextRange.start)
                let selectionEndRect = textView.caretRect(for: selectedTextRange.end)
                
                let selectionLocation = CGPoint(x: textView.textContainerInset.left, y: selectionStartRect.minY)
                let selectionHeight = selectionEndRect.maxY - selectionStartRect.minY
                
                let frame = CGRect(origin: selectionLocation, size: CGSize(width: 3, height: selectionHeight))
                
                let acrossFrames = exclusionManager.getAcrossFrames(frame)
                let views = exclusionManager.getAcrossViews(with: acrossFrames)
                views.forEach { $0.removeFromSuperview()}
                exclusionManager.removeExclusionView(with: acrossFrames)
                let noteView = UIView(frame: frame)
                noteView.backgroundColor = UIColor.systemRed
                exclusionManager.addExclusionView(noteView)
                textView.addSubview(noteView)
             
               
                var exclusionPaths: [UIBezierPath] = []
                
                exclusionManager.exclusionFrames.forEach {
                    var frame = $0
                    frame.origin.x = 0
                    frame.size.width = 10
                    let path = UIBezierPath(rect: frame)
                    exclusionPaths.append(path)
                }
                
                textContainer.exclusionPaths = exclusionPaths
            }
        }
    }
    
    
    @objc func textViewTapGesture(sender: UITapGestureRecognizer) {
        if let textView = sender.view as? UITextView {
            
            let layoutManager = textView.layoutManager
            var location = sender.location(in: textView)
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

// MARK: - 监听 selectedRange 处理对应字体风格
extension MarkdownViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        
//        if !tapLocationHasText {
//            return
//        }
        updateTypesettingBarStatus()
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
        updateFontStyle(with: textStorage.selectedStyles)
    }
    
    /// 更新字体风格
    func updateFontStyle(with styles: [MarkdownStorage.Style]) {
        styleBarGroupView.fontStyleBar.resetStyleToNoneSelect()
        styles.forEach {
            if $0 == [.bold, .italic] {
                [0, 1].forEach { styleBarGroupView.fontStyleBar.updateStyleItem(at: $0, selected: true) }
            } else {
                styleBarGroupView.fontStyleBar.updateStyleItem(at: $0.traitsIndex, selected: true)
            }
        }
    }
    
    func updateTypesettingBarStatus() {
        if let selectedTextRange = textView.selectedTextRange {
            
            let selectionStartRect = textView.caretRect(for: selectedTextRange.start)
            let selectionEndRect = textView.caretRect(for: selectedTextRange.end)
            
            let selectionLocation = CGPoint(x: textView.textContainerInset.left, y: selectionStartRect.minY)
            let selectionHeight = selectionEndRect.maxY - selectionStartRect.minY
            
            let frame = CGRect(origin: selectionLocation, size: CGSize(width: 3, height: selectionHeight))
            
            let acrossFrames = exclusionManager.getAcrossFrames(frame)
            if acrossFrames.count > 1 || acrossFrames.count == 0 {
                styleBarGroupView.typesettingBar.updateStyleItem(at: 0, selected: false)
                return
            }
            
            if acrossFrames.count == 1 {
                styleBarGroupView.typesettingBar.updateStyleItem(at: 0, selected: true)
                return
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
