//
//  TITextImage.swift
//  StopMotionStudio
//
//  Created by Shuntaro Kasatani on 6/13/20.
//  Copyright © 2020 Shuntaro Kasatani. All rights reserved.
//

import UIKit

class TITextImage {
    func addText(toImage image: UIImage, string text: String, textColor: UIColor) -> UIImage {       
        let font = UIFont.systemFont(ofSize: 32)
        let imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        UIGraphicsBeginImageContext(image.size);
        
        image.draw(in: imageRect)
        
        let textRect  = CGRect(x: 5, y: 5, width: image.size.width - 5, height: image.size.height - 5)
        let textFontAttributes: [NSAttributedString.Key : Any]? = [
            .font : font,
            .foregroundColor : textColor
        ]
        
        text.draw(in: textRect, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
