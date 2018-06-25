//
//  ImageCell.swift
//  Virtual Tourist
//
//  Created by SherifShokry on 6/25/18.
//  Copyright © 2018 SherifShokry. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    var photo : Photo?  {
        didSet{
            guard let cellPhoto = photo?.photo else { return }
            flickrImage.image = cellPhoto
        }
    }
    
    let flickrImage : UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .yellow
        
        addSubview(flickrImage)
        flickrImage.anchor(top: topAnchor, bottom: bottomAnchor, left: leadingAnchor, right: trailingAnchor, topPadding: 0, bottomPadding: 0, leftPadding: 0, rightPadding: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
