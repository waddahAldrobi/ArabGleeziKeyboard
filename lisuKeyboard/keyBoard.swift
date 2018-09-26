//
//  keyBoard.swift
//  lisuKeyboard
//
//  Created by Amos Gwa on 12/22/16.
//  Copyright © 2016 Amos Gwa. All rights reserved.
//

import Foundation
import UIKit


// TODO :: There is a linker problem in lisuKeyboardLayoutout global function.
// The build error indicates that this global struct cannot be linked to
// the gloal function.

struct MODE_CHANGE_ID {
    static let unshift = 1
    static let shift = 2
    static let sym = 3
    static let num = 4
    static let del = 5
}

// Colors
struct theme {
    static let keyPressedColor : UIColor = UIColor(red:0.73, green:0.73, blue:0.73, alpha:1.0)
    static let keyboardBackgroundColor : UIColor = UIColor(red:0.85, green:0.86, blue:0.86, alpha:1.0)
    static let keyBackgroundColor : UIColor = UIColor.white
    static let keyBorderColor : UIColor = UIColor.darkGray
    static let keyShadowColor : UIColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0)
    static let keyColor : UIColor = UIColor.darkGray
    static let subscriptKeyColor : UIColor = UIColor.gray
    static let specialKeyBackgroundColor : UIColor = UIColor(red:0.77, green:0.80, blue:0.81, alpha:1.0)
    static let specialKeyShadowColor : UIColor = UIColor(red:0.63, green:0.65, blue:0.66, alpha:0.6)
    static let keyboardTitleColor : UIColor = UIColor.lightGray
}

class Keyboard {
    // There are four pages unshift, shift, number , and symbols
    var keys: [Int:[[Key]]] = [:]
}
