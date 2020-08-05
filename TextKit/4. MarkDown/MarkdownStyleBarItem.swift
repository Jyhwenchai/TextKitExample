//
//  MarkdownStyleBarItem.swift
//  TextKit
//
//  Created by 蔡志文 on 2020/8/5.
//

import UIKit

class MarkdownStyleItemView: UIView {

    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()
    
    var selected: Bool = false {
        didSet {
            imageView.tintColor = selected ? UIColor.systemRed : UIColor.systemBlue
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        addSubview(imageView)
    }
    
    convenience init(_ image: UIImage) {
        self.init(frame: .zero)
        imageView.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
}
