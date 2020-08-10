//
//  ExclusionItem.swift
//  TextKit
//
//  Created by 蔡志文 on 2020/8/7.
//

import UIKit

class ExclusionManager {
    var exclusionViews: [UIView] = []
    
    var exclusionFrames: [CGRect] {
        exclusionViews.map(\.frame)
    }
    
    
    var exclusionPositions: [CGPoint] {
        exclusionViews.map {
            CGPoint(x: 0, y: $0.frame.maxY - $0.frame.minY)
        }
    }
    
    
    var paths: [UIBezierPath] {
        let frames = exclusionViews.map { view -> CGRect in
            var frame = view.frame
            frame.origin.x = 0
            frame.size.width = 10
            return frame
        }
        return frames.map {
            UIBezierPath(rect: $0)
        }
    }
    
    
    func getAcrossFrames(_ rect: CGRect) -> [CGRect] {
        
        // 1. 获取已有视图的frame
        var frames = exclusionViews.map { $0.frame }
        let originFrames = frames
        // 2. 获取准备绘制视图的开始位置和结束位置
        let startPosition = rect.origin
        let endPosition = CGPoint(x: rect.minX, y: rect.maxY)
    
        // 3. 判断开始位置和结束位置是否跨越多个以绘制的视图
        frames = frames.filter { rect.contains($0) || $0.contains(startPosition) || $0.contains(endPosition) }
        let acrossFrames = originFrames.filter { frames.contains($0) }
        
        return acrossFrames
    }
    
    func getAcrossViews(with rects: [CGRect]) -> [UIView] {
        return exclusionViews.filter { rects.contains($0.frame) }
    }
    
    // 1. 获取选中区域即将绘制的视图
    // 2. 判断要绘制的视图是否还未绘制、或者以绘制、如果已绘制是否跨越多个视图
    
    func addExclusionView(_ view: UIView) {
        exclusionViews.append(view)
        exclusionViews = exclusionViews.sorted {
            $0.frame.minY < $1.frame.minY
        }
    }
    
    /// 移除选中高亮范围的视图
    func removeExclusionView(with frames: [CGRect]) {
        var exclusionIndexes: [Int] = []
        for (index, view) in exclusionViews.enumerated() {
            for frame in frames where frame == view.frame {
                exclusionIndexes.append(index)
                break
            }
        }
        
    
        exclusionIndexes.reversed().forEach {
            exclusionViews.remove(at: $0)
        }
    }
    
}
