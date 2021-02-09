//
//  UIImage+Extensions.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 09/02/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

extension UIImage {
    
    func split(intoRows rows: Int, columns: Int, shouldContainPlaceholder: Bool) -> Result<[[UIImage]], Error> {
        
        let height = size.height / CGFloat(rows)
        let width = size.width / CGFloat(columns)
        
        var images = [[UIImage]]()
        
        for y in 0 ..< rows {
            var rowImages = [UIImage]()
            for x in 0 ..< columns {
                
                UIGraphicsBeginImageContextWithOptions(
                    CGSize(width:width, height:height),
                    false, 0)
                let imageBlock = cgImage?.cropping(to:  CGRect(x: CGFloat(x) * width * scale, y:  CGFloat(y) * height * scale  , width: width * scale  , height: height * scale) )
                
                if imageBlock == nil {
                    let error = NSError(domain: "UIImage", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not split image"])
                    return .failure(error)
                }
                
                rowImages.append(UIImage(cgImage: imageBlock!))
                
                UIGraphicsEndImageContext();
                
            }
            
            images.append(rowImages)
        }
        
        if shouldContainPlaceholder {
            images[rows - 1][columns - 1] = UIImage() // change to default move image
        }
        
        return .success(images)
        
    }
    
}

