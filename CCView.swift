//
//  CCView.swift
//  StopMotionStudio
//
//  Created by Shuntaro Kasatani on 6/7/20.
//  Copyright © 2020 Shuntaro Kasatani. All rights reserved.
//

import UIKit

class PagingPerCellFlowLayout: UICollectionViewFlowLayout {
    
    var cellWidth: CGFloat = 0.0
    let windowWidth: CGFloat = UIScreen.main.bounds.width
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        cellWidth = super.itemSize.width
        var offsetAdjustment: CGFloat = CGFloat(MAXFLOAT)
        let horizontalOffest: CGFloat = proposedContentOffset.x + (windowWidth - cellWidth) / 2
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: self.collectionView!.bounds.size.width, height: self.collectionView!.bounds.size.height)
        
        let array = super.layoutAttributesForElements(in: targetRect)
        
        for layoutAttributes in array! {
            let itemOffset = layoutAttributes.frame.origin.x
            if abs(itemOffset - horizontalOffest) < abs(offsetAdjustment) {
                offsetAdjustment = itemOffset - horizontalOffest
            }
        }
        
        return CGPoint(x:proposedContentOffset.x + offsetAdjustment, y:proposedContentOffset.y)
    }
}

/// ページングを実装します。
class CCView: UICollectionView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    convenience init(frame: CGRect) {
        let layout = PagingPerCellFlowLayout()
        layout.scrollDirection = .horizontal
        self.init(frame: frame, collectionViewLayout: layout)
    }
    
    func transformScale(cell: UICollectionViewCell) {
        // 計算してスケールを変更する
        let cellCenter: CGPoint = self.convert(cell.center, to: nil) // セルの中心座標
        let screenCenterX: CGFloat = UIScreen.main.bounds.width / 2  // 画面の中心座標X
        let reductionRatio: CGFloat = -0.0009                        // 縮小率
        let maxScale: CGFloat = 1                                    // 最大値
        let cellCenterDisX: CGFloat = screenCenterX - cellCenter.x   // 中心までの距離
        let newScale = reductionRatio * cellCenterDisX + maxScale   // 新しいスケール
        cell.transform = CGAffineTransform(scaleX: newScale, y: newScale)
    }
    
}

extension CCView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 画面内に表示されているセルを取得
        let cells = self.visibleCells
        for cell in cells {
            // ここでセルのScaleを変更する
            transformScale(cell: cell)
        }
    }
}
