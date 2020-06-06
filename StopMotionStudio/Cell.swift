//
//  ViewController.swift
//  StopMotionStudio
//
//  Created by Shuntaro Kasatani on 6/2/20.
//  Copyright © 2020 Shuntaro Kasatani. All rights reserved.
//

import UIKit

class ProjectItem: NSObject {
    var string: String?
    var image: UIImage?
    init(image: UIImage?, forName string: String) {
        self.string = string
        if let image = image {
            self.image = image
        }
    }
}

class CustomCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    // チェックマーク画像の Asset を用意すること
    let checkmarkImage: UIImage = UIImage(named: "CheckMark")!
    var checkmarkView: UIImageView!
    
    var isMarked: Bool = false {
        didSet {
            let text = self.viewWithTag(1) as! UILabel
            if text.text != "新規作成" {
                if self.isMarked {
                    self.contentView.addSubview(self.checkmarkView!)
                    self.isHighlighted = true
                } else {
                    self.checkmarkView?.removeFromSuperview()
                    self.isHighlighted = false
                }
            }
        }
    }
    
    func clearCheckmark() -> Void {
        self.isMarked = false
    }
    
    override func addSubview(_ view: UIView) {
        self.checkmarkView = UIImageView(image: self.checkmarkImage)
        super.addSubview(view)
    }
    
}
