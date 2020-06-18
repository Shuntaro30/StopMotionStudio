//
//  TITextImage.swift
//  StopMotionStudio
//
//  Created by Shuntaro Kasatani on 6/13/20.
//  Copyright © 2020 Shuntaro Kasatani. All rights reserved.
//

import UIKit

class TITextImage {
    func addText(_ image: UIImage, color: UIColor, text: String) -> UIImage {
        let font = UIFont.boldSystemFont(ofSize: 32)
        let imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        UIGraphicsBeginImageContext(image.size);
        
        image.draw(in: imageRect)
        
        let textRect  = CGRect(x: 5, y: 5, width: image.size.width - 5, height: image.size.height - 5)
        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        let textFontAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.paragraphStyle: textStyle
        ]
        text.draw(in: textRect, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
