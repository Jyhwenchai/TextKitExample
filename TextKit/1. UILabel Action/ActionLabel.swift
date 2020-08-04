//
//  ActionLabel.swift
//  TextKit
//
//  Created by 蔡志文 on 2020/8/3.
//

import UIKit

typealias AttributedTextAction = (NSAttributedString) -> Void

class ActionLabel: UILabel {

    var attributedStrings: [NSAttributedString] = []
    var attributedStringRanges: [NSRange] = []
    var attributedTextActions: [AttributedTextAction] = []
    
    let textStorage: NSTextStorage = NSTextStorage()
    let layoutManager: NSLayoutManager = NSLayoutManager()
    let textContainer: NSTextContainer = NSTextContainer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isUserInteractionEnabled = true
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textContainer.size = bounds.size
    }
    
    override func drawText(in rect: CGRect) {
        let range = NSRange(location: 0, length: textStorage.length)
        layoutManager.drawBackground(forGlyphRange: range, at: .zero)
        layoutManager.drawGlyphs(forGlyphRange: range, at: .zero)
    }
    
    func append(string: NSAttributedString, action: @escaping AttributedTextAction) {
        attributedStrings.append(string)
        attributedTextActions.append(action)
        let range = NSRange(location: textStorage.length, length: string.length)
        attributedStringRanges.append(range)
        textStorage.append(string)
    }
}

extension ActionLabel {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let point = touch.location(in: self)
        
        // 根据点击位置获取glyph(字形)的索引
        let glyphIndex = layoutManager.glyphIndex(for: point, in: textContainer)
        // 获取glyph所在的区域
        let glyphRect = layoutManager.boundingRect(forGlyphRange: NSRange(location: glyphIndex, length: 1), in: textContainer)
        // 判断点击的glyph所在区域是否包含点击的点
        if glyphRect.contains(point) {
            // 获取点击的字符
            let charactorIndex = layoutManager.characterIndexForGlyph(at: glyphIndex)
            for (index, range) in attributedStringRanges.enumerated() where NSLocationInRange(charactorIndex, range) {
                let action = attributedTextActions[index]
                action(attributedStrings[index])
            }
        }
        
    }
}

// MARK: - Computed properties
extension ActionLabel {
    override var text: String? {
        didSet {
            if let _ = text {
                text = nil
            }
        }
    }
    
    override var attributedText: NSAttributedString? {
        didSet {
            if let _ = attributedText {
                attributedText = nil
            }
        }
    }
}
