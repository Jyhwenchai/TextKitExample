//
//  ExclusionPathViewController.swift
//  TextKit
//
//  Created by 蔡志文 on 2020/8/4.
//

import UIKit

class ExclusionPathViewController: UIViewController {

    @IBOutlet var textView: UITextView!
    
    var panOffset: CGPoint = .zero
    
    
    let exclusionView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
        view.backgroundColor = UIColor.systemBlue
        view.isUserInteractionEnabled = true
        view.layer.cornerRadius = 50
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textView.backgroundColor = UIColor.lightGray
        
        exclusionView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(pan:))))
        exclusionView.center = self.textView.center
        
        view.addSubview(exclusionView)
        updateExclusionPath()
    }
    
    @objc func panGestureAction(pan: UIPanGestureRecognizer) {
        
        if pan.state == .began {
            panOffset = pan.location(in: exclusionView)
        }
        
        let location = pan.location(in: view)
        var exclusionCenter = exclusionView.center
        
        exclusionCenter.x = location.x - panOffset.x + exclusionView.bounds.width / 2
        exclusionCenter.y = location.y - panOffset.y + exclusionView.bounds.height / 2
        exclusionView.center = exclusionCenter
        
        updateExclusionPath()
        
    }
    
    func updateExclusionPath() {
        var exclusionFrame = exclusionView.frame
        exclusionFrame.origin.x -= textView.textContainerInset.left
        exclusionFrame.origin.y -= textView.textContainerInset.top
        exclusionFrame.origin.y -= textView.frame.origin.y
        print(exclusionFrame)
        let exclusionPath = UIBezierPath(ovalIn: exclusionFrame)
        textView.textContainer.exclusionPaths = [exclusionPath]
    }
}
