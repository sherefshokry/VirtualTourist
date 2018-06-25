//
//  ImageController.swift
//  Virtual Tourist
//
//  Created by SherifShokry on 6/25/18.
//  Copyright © 2018 SherifShokry. All rights reserved.
//

import UIKit

class ImageController: UIViewController , UIGestureRecognizerDelegate{

    var photo: Photo? {
        didSet{
            guard let  photo = photo?.photo else { return }
            selectedImage.image = photo
        }
    }
    
    
    
    let selectedImage : UIImageView = {
       let imageView = UIImageView()
       return imageView
    }()
    
    let label : UILabel = {
       let label = UILabel()
        label.text = "Double-Tap to dismiss"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    
    func doubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(closeVC))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        self.view.addGestureRecognizer(doubleTap)
    }
    @objc func closeVC(){
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(selectedImage)
        
        selectedImage.anchor(top: view.topAnchor, bottom: view.bottomAnchor, left: view.leadingAnchor, right: view.trailingAnchor, topPadding: 0,bottomPadding: 0, leftPadding: 0, rightPadding: 0, width: 0, height: 0)
        
        doubleTap()
        
        view.addSubview(label)
        
        label.anchor(top: nil, bottom: view.bottomAnchor, left: view.leadingAnchor, right: view.trailingAnchor, topPadding: 00, bottomPadding: 10, leftPadding: 0, rightPadding: 0, width: 0, height: 50)
       
        
    }

   


}
