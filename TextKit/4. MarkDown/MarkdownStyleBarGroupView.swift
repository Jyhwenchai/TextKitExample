//
//  MarkdownStyleBarGroupView.swift
//  TextKit
//
//  Created by 蔡志文 on 2020/8/7.
//

import UIKit


class MarkdownStyleBarGroupView: UIView {
    
    lazy var fontStyleBar: MarkdownStyleBar = {
        let bar = MarkdownStyleBar(styleItems)
        bar.isMultipleSelection = true
        return bar
    }()
    
    lazy var imageBar: MarkdownStyleBar = {
        let bar = MarkdownStyleBar([MarkdownStyleBar.Item(UIImage(systemName: "photo")!)])
        bar.isSelectionHighlight = false
        return bar
    }()
    
    lazy var typesettingBar: MarkdownStyleBar = {
        let bar = MarkdownStyleBar(typesettingItems)
        return bar
    }()
    
    var fontStyleSelectionHandler: (([Int]) -> Void)? {
        get {
            return fontStyleBar.selectionHandler
        }
        set {
            fontStyleBar.selectionHandler = newValue
        }
    }
    
    var imageStyleSelectionHandler: (() -> Void)?
    var typesettingSelectionHandler: ((Int) -> Void)?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 5.0
        backgroundColor = UIColor.systemGray5
        addSubview(imageBar)
        addSubview(fontStyleBar)
        addSubview(typesettingBar)
        initActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageBar.frame = CGRect(origin: CGPoint(x: 10, y: 0), size: CGSize(width: 45, height: 45))
        fontStyleBar.frame = CGRect(x: imageBar.frame.maxX, y: 0.0, width: 45.0 * CGFloat(styleItems.count), height: 45.0)
        typesettingBar.frame = CGRect(x: fontStyleBar.frame.maxX, y: 0.0, width: 45 * CGFloat(typesettingItems.count), height: 45.0)
    }
    
    func initActions() {
        imageBar.selectionHandler = { [weak self] _ in
            guard let self = self else { return }
            self.imageStyleSelectionHandler?()
        }
        
        typesettingBar.selectionHandler = { [weak self] indexs in
            guard let self = self else { return }
            self.typesettingSelectionHandler?(indexs.first!)
        }
    }
    
}

extension MarkdownStorage.Style {
    static var segmentItemNames: [String] {
        return ["Normal", "Bold", "Italic", "Underline", "Strike"]
    }
}

private var styleItems: [MarkdownStyleBar.Item] = [
    MarkdownStyleBar.Item(UIImage(systemName: "bold")!),
    MarkdownStyleBar.Item(UIImage(systemName: "italic")!),
    MarkdownStyleBar.Item(UIImage(systemName: "underline")!),
    MarkdownStyleBar.Item(UIImage(systemName: "strikethrough")!)
]

private var typesettingItems: [MarkdownStyleBar.Item] = [
    MarkdownStyleBar.Item(UIImage(systemName: "decrease.quotelevel")!),
    MarkdownStyleBar.Item(UIImage(systemName: "list.bullet")!),
    MarkdownStyleBar.Item(UIImage(systemName: "list.number")!)
]

