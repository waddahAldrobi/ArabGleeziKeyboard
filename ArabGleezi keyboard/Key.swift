//
//  Key.swift
//  lisuKeyboard
//
//  Created by Amos Gwa on 12/21/16.
//  Copyright © 2016 Amos Gwa. All rights reserved.
//

import Foundation
import UIKit

class Key{
    enum KeyType {
        case character
        case shift
        case backspace
        case modeChange
        case keyboardChange
        case space
        case num
        case sym
        case enter
        case settings
        case other
    }
    
    var type: KeyType
    var keyValue: String?
    var keyImage: String?
    var button = keyButton(type: .custom)
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    var parentView = UIView()
    var tag: Int = 0 // Tag is 0 by default
    
    // This is a hack.
    var GAP_SIZE = CGSize()
    
    init() {
        // Place holder
        self.type = KeyType.character
        self.keyValue = ""
    }
    
    init(type: KeyType, keyValue: String? = nil, keyImage: String? = nil , width: CGFloat, height: CGFloat, parentView: UIView, tag: Int? = nil, gapSize: CGSize? = nil) {
        self.type = type
        self.width = width
        self.height = height
        self.parentView = parentView
      
        if tag != nil {
            self.tag = tag!
        }
        
        // Hack to detect touches between the gaps.
        // It makes the keyboard feel more responsive.
        if gapSize != nil {
            self.GAP_SIZE = gapSize!
            self.button.setInset(gapX: (gapSize?.width)!, gapY: (gapSize?.height)!)
        }
        
        // Determines the button type using MODE_CHANGE_ID
        self.button.tag = self.tag
        
        // Buttons are hidden by default.
        self.button.isHidden = true
        
        // This assign a parent view to the button
        // This is need to set the constraints.
        parentView.addSubview(self.button)
                
        // Set value or image for the button
        if keyImage != nil {
            self.keyImage = keyImage!
            // Change color of the image 
            let tintedImage = UIImage(named : self.keyImage!)?.withRenderingMode(.alwaysTemplate)         
          
          let _isPortrait = self.width < self.height
          
          if _isPortrait {
            self.button.imageEdgeInsets = UIEdgeInsets(top: 0,left: 0.2*self.width,bottom: 0,right: 0.2*self.width)
          } else {
            self.button.imageEdgeInsets = UIEdgeInsets(top: 0.2*self.height,left: 0,bottom: 0.2*self.height,right: 0)
          }
            
            self.button.imageView?.contentMode = UIViewContentMode.scaleAspectFit
            self.button.imageView?.tintColor = theme.keyColor
            self.button.setImage(tintedImage, for: [])
        } else if keyValue != nil {
            self.keyValue = keyValue!
            self.button.setTitle(self.keyValue!, for: [])
        }
        
        
        // Style the button
        self.button.setTitleColor(theme.keyColor, for: [])
        self.button.layer.cornerRadius = 5
        self.button.backgroundColor = self.isSpecial ? theme.specialKeyBackgroundColor : theme.keyBackgroundColor
        self.button.layer.borderColor = theme.keyBorderColor.cgColor
        
        // Add shadow to button
        self.button.layer.masksToBounds = false // Required for adding shadow.
        self.button.layer.shadowColor = self.isSpecial ? theme.specialKeyShadowColor.cgColor : theme.keyShadowColor.cgColor
        self.button.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.button.layer.shadowOpacity = 1
        self.button.layer.shadowRadius = 0
        
        // Button Constraint
        self.button.sizeToFit()
        self.button.widthAnchor.constraint(equalToConstant: width).isActive = true
        self.button.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.button.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func copy(type: KeyType? = nil, keyValue: String? = nil, keyImage: String? = nil, width: CGFloat? = nil, height: CGFloat? = nil) -> Key{
        let copyObj = Key(type: (type != nil ? type! : self.type), keyValue: (keyValue != nil ? keyValue! : self.keyValue), keyImage: (keyImage != nil ? keyImage! : self.keyImage), width: (width != nil ? width! : self.width), height: (height != nil ? height! : self.height), parentView: self.parentView, tag: self.tag, gapSize: self.GAP_SIZE)
        return copyObj
    }
    
    func addSubscript(subScript: String, isIPad: Bool){
        // Add a subscript
        let keyLabel = UILabel()
        
        if isIPad {
            keyLabel.setSizeFont(sizeFont: (self.button.titleLabel?.font.pointSize)! * 0.70)
        }
        else {
            keyLabel.setSizeFont(sizeFont: (self.button.titleLabel?.font.pointSize)! * 0.50)
        }
        
        // Add the subscript key label to the button.
        self.button.addSubview(keyLabel)
        
        // Add constraint to the subscript key label.
        keyLabel.widthAnchor.constraint(equalToConstant: keyLabel.font.pointSize).isActive = true
        keyLabel.heightAnchor.constraint(equalToConstant: keyLabel.font.pointSize).isActive = true
        keyLabel.rightAnchor.constraint(equalTo: self.button.rightAnchor, constant: -self.width/12).isActive = true
        keyLabel.topAnchor.constraint(equalTo: self.button.topAnchor, constant: self.width/12).isActive = true
        
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        keyLabel.textAlignment = NSTextAlignment.center
        keyLabel.textColor = theme.subscriptKeyColor
        keyLabel.text = (subScript)
    }
    
    var isSpecial: Bool {
        get {
            switch self.type {
            case .shift:
                return true
            case .backspace:
                return true
            case .modeChange:
                return true
            case .keyboardChange:
                return true
            case .enter:
                return true
            case .settings:
                return true
            default:
                return false
            }
        }
    }
}
