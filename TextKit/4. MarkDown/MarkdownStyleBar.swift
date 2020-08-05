//
//  MarkdownStyleBar.swift
//  TextKit
//
//  Created by 蔡志文 on 2020/8/5.
//

import UIKit

class MarkdownStyleBar: UIView {

    struct Item {

        var selected: Bool = false
        
        var icon: UIImage
        
        init(_ icon: UIImage) {
            self.icon = icon
        }

    }
    
    var isMultipleSelection: Bool = false
    
    var items: [Item] = []
    
    var selectionHandler: (([Int]) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(_ items: [Item]) {
        self.init(frame: .zero)
        self.items = items
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if subviews.count > 0 {
            return
        }
        
        for (index, item) in items.enumerated() {
            let itemView = MarkdownStyleItemView(item.icon)
            let width: CGFloat = 45
            itemView.frame = CGRect(x: CGFloat(index) * width, y: 0, width: width, height: bounds.height)
            itemView.tag = index
            itemView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(markdownStyleItemAction(gesture:))))
            addSubview(itemView)
        }
    }
    
    
    @objc func markdownStyleItemAction(gesture: UITapGestureRecognizer) {
        guard let styleView = gesture.view as? MarkdownStyleItemView else { return }
        styleView.selected.toggle()
        if !isMultipleSelection {
            let newItems = items.map { item -> Item in
                var newItem = item
                newItem.selected = false
                return newItem
            }
            items = newItems
        }
        
        var item = items[styleView.tag]
        item.selected.toggle()
        items[styleView.tag] = item
        completeAction()
    }
    
    func completeAction() {
        var indexes: [Int] = []
        for (index, item) in items.enumerated() where item.selected {
            indexes.append(index)
        }
        selectionHandler?(indexes)
    }
}
