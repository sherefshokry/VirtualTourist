//
//  Extenstions.swift
//  Virtual Tourist
//
//  Created by SherifShokry on 6/12/18.
//  Copyright © 2018 SherifShokry. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func rgb(red: CGFloat ,green: CGFloat ,blue: CGFloat) -> UIColor{
        
        return  UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
        
    }
    
}

extension UIViewController {
    func  presentDetails(_ viewControllerToPresent: UIViewController ) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        present(viewControllerToPresent, animated: false, completion: nil)
    }
    
    
    func dismissDetail(){
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false, completion: nil)
        
    }
    
}



extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor?, bottom: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, right: NSLayoutXAxisAnchor?, topPadding: CGFloat , bottomPadding: CGFloat, leftPadding:CGFloat , rightPadding: CGFloat , width: CGFloat , height: CGFloat)
    {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top
        {
            topAnchor.constraint(equalTo: top, constant: topPadding).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -bottomPadding).isActive = true
        }
        
        if let left = left {
            leadingAnchor.constraint(equalTo: left, constant: leftPadding).isActive = true
        }
        
        if let right = right {
            trailingAnchor.constraint(equalTo: right, constant: -rightPadding).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    
        
    }
    
    
}
