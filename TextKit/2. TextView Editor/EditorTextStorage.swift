//
//  EditorTextStorage.swift
//  TextKit
//
//  Created by 蔡志文 on 2020/8/3.
//

import UIKit

class EditorTextStorage: NSTextStorage {

    var storageAttributedString: NSMutableAttributedString = NSMutableAttributedString()
    let regxExpression: NSRegularExpression = try! NSRegularExpression(pattern: #"~\w+\s*\w*~"#, options: [])
    
    override var string: String {
        return storageAttributedString.string
    }
    
    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        return storageAttributedString.attributes(at: location, effectiveRange: range)
    }
    
    override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        beginEditing()
        storageAttributedString.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
    
    override func processEditing() {
        super.processEditing()
        // 去除当前颜色属性
        let paragraphRange = (string as NSString).paragraphRange(for: editedRange)
        removeAttribute(.foregroundColor, range: paragraphRange)
        // 根据正则匹配重新添加颜色属性
        regxExpression.enumerateMatches(in: string, options: .reportProgress, range: paragraphRange) { (result, flags, stop) in
            if let result = result {
                addAttribute(.foregroundColor, value: UIColor.systemBlue, range: result.range)
            }
        }
    }
    
    override func replaceCharacters(in range: NSRange, with str: String) {
        beginEditing()
        storageAttributedString.replaceCharacters(in: range, with: str)
        edited(.editedCharacters, range: range, changeInLength: str.count - range.length)
        endEditing()
    }
}

