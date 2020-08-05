//
//  MarkdownStorage.swift
//  TextKit
//
//  Created by 蔡志文 on 2020/8/5.
//

import UIKit

class MarkdownStorage: NSTextStorage {

    var storeAttributedString: NSMutableAttributedString = NSMutableAttributedString()
    var selectedStyles: [Style] = [.normal]
    var selectedRange: NSRange = NSRange()
    var lastEditedLength: Int = 0
    
    struct Style: OptionSet {
        var rawValue: Int
        init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        static let normal = Style(rawValue: -1)
        static let bold = Style(rawValue: 1 << 0)
        static let italic = Style(rawValue: 1 << 1)
        static let underline = Style(rawValue: 1 << 2)
        static let strike = Style(rawValue: 1 << 3)
    }
 
}

extension MarkdownStorage {
    override var string: String {
        return storeAttributedString.string
    }

    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        return storeAttributedString.attributes(at: location, effectiveRange: range)
    }
    
    override func replaceCharacters(in range: NSRange, with str: String) {
        beginEditing()
        storeAttributedString.replaceCharacters(in: range, with: str)
        edited(.editedCharacters, range: range, changeInLength: str.count - range.length)
        endEditing()
    }
    
    override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        beginEditing()
        storeAttributedString.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
}

extension MarkdownStorage {
    // 将文本的变化通知给布局管理器。
    override func processEditing() {
        var applyRange = selectedRange
        applyRange.length = editedRange.location + editedRange.length - selectedRange.location
        replaceEditorRange(applyRange)
        super.processEditing()
    }
    
    private func replaceEditorRange(_ changeRange: NSRange) {
        
        resetNormalStyle(with: changeRange)
        
        selectedStyles.forEach {
            addAttributes($0.attributes, range: changeRange)
        }
    }
    
    func update() {
        replaceEditorRange(selectedRange)
    }
}

extension MarkdownStorage.Style {
    var attributes: [NSAttributedString.Key: Any] {
        
        let bodyFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        let scriptFontDescriptor = UIFontDescriptor(fontAttributes: [.family: "PingFang SC"])
        let boldFontSize = bodyFontDescriptor.fontAttributes[.size] as! CGFloat
        let scriptFont = UIFont(descriptor: scriptFontDescriptor, size: boldFontSize)
         
        switch self {
        case .bold:
            let boldDescriptor = bodyFontDescriptor.withSymbolicTraits(.traitBold)
            // size值为0，会迫使UIFont返回用户设置的字体大小。
            let fontBold = UIFont(descriptor: boldDescriptor!, size: 0.0)
            return [.font: fontBold]
        case .italic:
            let italicDescriptor = bodyFontDescriptor.withSymbolicTraits(.traitItalic)
            let fontItalic = UIFont(descriptor: italicDescriptor!, size: 0.0)
            return [.font: fontItalic]
        case [.bold, .italic]:
            let italicDescriptor = bodyFontDescriptor.withSymbolicTraits([.traitItalic, .traitBold])
            let fontItalic = UIFont(descriptor: italicDescriptor!, size: 0.0)
            return [.font: fontItalic]
        case .underline:
            return [.underlineStyle: 2, .underlineColor: UIColor.systemBlue]
        case .strike:
            return [.strikethroughStyle: 2, .strikethroughColor: UIColor.red]
        default: return [.font: scriptFont]
        }
    }
}

extension MarkdownStorage {
    
    func removeAllStyle(with range: NSRange) {
        clearBoldStyle(with: range)
        clearItalicStyle(with: range)
        clearUnderlineStyle(with: range)
        clearStrikeStyle(with: range)
    }
    
    func resetNormalStyle(with range: NSRange) {
        removeAllStyle(with: range)
        addAttributes(MarkdownStorage.Style.normal.attributes, range: range)
    }
    
    func clearBoldStyle(with range: NSRange) {
        removeAttribute(.font, range: range)
    }
    
    func clearItalicStyle(with range: NSRange) {
        removeAttribute(.font, range: range)
    }
    
    func clearUnderlineStyle(with range: NSRange) {
        removeAttribute(.underlineStyle, range: range)
        removeAttribute(.underlineColor, range: range)
    }
    
    func clearStrikeStyle(with range: NSRange) {
        removeAttribute(.strikethroughStyle, range: range)
        removeAttribute(.strikethroughColor, range: range)
    }

}
