//
//  lisuKeyboardLayout.swift
//  lisuKeyboard
//
//  Created by Amos Gwa on 12/22/16.
//  Copyright © 2016 Amos Gwa. All rights reserved.
//

import Foundation
import UIKit

struct page {
    var keyboard : [[String]] = []
}

func lisuKeyboardLayout(controller: UIInputViewController, totalWidth: CGFloat, totalHeight: CGFloat, isPortrait: Bool, isIPad: Bool) -> Keyboard {
       
    struct MODE_CHANGE_ID {
        static let unshift = 1
        static let shift = 2
        static let sym = 3
        static let num = 4
        static let del = 5
    }
    
    let viewWidth = totalWidth
    let viewHeight = isIPad ? totalHeight : totalHeight / 1.15
    var barHeight = isIPad ? 0 : totalHeight * 0.15
  
    // Ipad and iOS lower than 10 doesn't have the top bar.
    if #available(iOSApplicationExtension 9.0, *){
    } else {
      barHeight = 0.0
    }
    
//    // NEED AN EXTRA BAR ON THE TOP FOR THE POPUP. ONLY FOR iPHONES
    let topBar = UIToolbar()


    controller.view.addSubview(topBar)
    topBar.widthAnchor.constraint(equalToConstant: viewWidth).isActive = true
    topBar.heightAnchor.constraint(equalToConstant: barHeight).isActive = true
    topBar.topAnchor.constraint(equalTo: controller.view.topAnchor).isActive = true
    topBar.rightAnchor.constraint(equalTo: controller.view.rightAnchor).isActive = true
    topBar.translatesAutoresizingMaskIntoConstraints = false
    topBar.backgroundColor = theme.keyboardBackgroundColor
  
    // Just to save myself from typos
    struct specialKey {
        static let shift = "shift"
        static let backspace = "backspace"
        static let num = "123"
        static let change = "keyboardchange"
        static let space = "space"
        static let sym = "Sym"
        static let enter = "return"
        static let ABC = "ABC"
    }
    
    struct specialCharacter{
        static let period = "."
        static let comma = ","
        static let askMark = "?"
        static let excMark = "!"
        static let apostrophe = "'"
    }
    
    // NOTE :: You cannot just simply replace the following chart.
    // Needs more work to be programmatic. More like a reference.
    
    var keyboardLayout : [Int: page] = [:]
    // Unshift
    var unshiftPage = page()
//    unshiftPage.keyboard = [["Q","ꓪ", "ꓰ", "ꓣ", "ꓔ", "ꓬ", "ꓴ", "ꓲ", "ꓳ", "ꓑ"],
//                            ["ꓮ", "ꓢ", "ꓓ", "ꓝ", "ꓖ", "ꓧ", "ꓙ", "ꓗ", "ꓡ"],
//                            ["shift","ꓜ", "ꓫ", "ꓚ", "ꓦ", "ꓐ", "ꓠ", "ꓟ","backspace"],
//                            ["123","keyboardchange", "space",".", "return"]
//    ]
    
    unshiftPage.keyboard = [["Q","W", "E", "R", "T", "Y", "U", "I", "O", "P"],
                            ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
                            ["shift","Z", "X", "C", "V", "B", "N", "M","backspace"],
                            ["123","keyboardchange", "space",".", "return"]
    ]
    
    
    
    keyboardLayout[MODE_CHANGE_ID.unshift] = unshiftPage
    // Shift
    var shiftPage = page()
    
    //In reverse
    shiftPage.keyboard = [["ق", "و", "ا", "ر", "ت", "ي", "و", "ي", "و", "ب"],
                    /*s*/["ا", "س", "د", "ف", "ج", "ه", "ج", "ك", "ل"],
                          ["unshift","ز", "ة", "ك", "ف", "ب", "ن", "م","backspace"],
                          ["123","keyboardchange", "space","?", "return"]
    ]
    keyboardLayout[MODE_CHANGE_ID.shift] = shiftPage
    // 123
    var numPage = page()
    numPage.keyboard = [["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
                        ["-", "/", ":", ";", "(", ")", "$", "&","@","\""],
                        ["sym",".", ",","ـً‎","?", "!", "'","backspace"],
                        ["ABC","keyboardchange", "space",",", "return"]
    ]
    keyboardLayout[MODE_CHANGE_ID.num] = numPage
    // Sym
    var symPage = page()
    symPage.keyboard = [["[", "]", "{", "}", "#", "%", "^", "*", "+", "="],
                        ["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "•"],
           /*h*/        ["123", "." , ",", "ـً‎", "?", "!", "'","backspace"],
                        ["ABC","keyboardchange", "space", "•", "return"]
    ]
    
    

    keyboardLayout[MODE_CHANGE_ID.sym] = symPage
    
    // Padding for the buttons
    let GAP_RATIO: CGFloat = 0.015
    var GAP_WIDTH: CGFloat = GAP_RATIO * viewWidth // 1.2% of the whole width
    
    if !isPortrait {
        GAP_WIDTH = GAP_RATIO * 0.66 * viewWidth
    }
    
    var GAP_HEIGHT: CGFloat = GAP_WIDTH * 1.75
    
    if !isPortrait {
        GAP_HEIGHT = GAP_WIDTH
    }
    
    let GAP_SIZE = CGSize(width: GAP_WIDTH, height: GAP_HEIGHT)
    
    let MAX_NUM_GAP_HOR: CGFloat = 11 // Max horizontal key is ten, so there are eleven gaps.
    let MAX_NUM_GAP_VER: CGFloat = 5 // There are five rows. So, five gaps
    
    // Determine button width
    // So many magic numbers... :<<<
    let characterSize = CGSize(width: (viewWidth-(GAP_WIDTH * MAX_NUM_GAP_HOR))/10, height: (viewHeight - (GAP_HEIGHT * MAX_NUM_GAP_VER))/4.5)
    let characterSize2Row = CGSize(width: (viewWidth-(GAP_WIDTH * MAX_NUM_GAP_HOR))/9.5, height: (viewHeight - (GAP_HEIGHT * MAX_NUM_GAP_VER))/4.5)
    let shiftDeleteSize = CGSize(width: (viewWidth - characterSize.width * 7 - GAP_WIDTH * 10)/2, height: characterSize.height ) // There are seven keys between shift and delete.
    let spacebarSize = CGSize(width: (characterSize.width * 5 + GAP_WIDTH * 4), height: characterSize.height)
    
    // Icons
    let changeKeyboardIcon = "globe.png"
    let enterIcon = "\u{000023CE}"
    let backspaceIcon = "\u{0000232B}"
    let shiftIcon = "\u{00021E7}"
    
    // Keyboard with associated pages
    let keyboard = Keyboard()
    keyboard.keys[MODE_CHANGE_ID.unshift] = []
    keyboard.keys[MODE_CHANGE_ID.shift] = []
    keyboard.keys[MODE_CHANGE_ID.num] = []
    keyboard.keys[MODE_CHANGE_ID.sym] = []
    
    // Reusable Keys
    let charKey = Key(type: .character, keyValue: "", width: characterSize.width, height: characterSize.height, parentView: controller.view, gapSize: GAP_SIZE)
    let charKey2Row = Key(type: .character, keyValue: "", width: characterSize2Row.width, height: characterSize.height, parentView: controller.view, gapSize: GAP_SIZE)
    let backspaceKey = Key(type: .backspace, keyValue: backspaceIcon, width: shiftDeleteSize.width, height: shiftDeleteSize.height, parentView: controller.view, tag: MODE_CHANGE_ID.del, gapSize: GAP_SIZE)
    let enterKey = Key(type: .enter, keyValue: enterIcon, width: shiftDeleteSize.width, height: characterSize.height, parentView: controller.view, gapSize: GAP_SIZE)
    let changeKeyboardKey = Key(type: .keyboardChange, keyImage: changeKeyboardIcon, width: characterSize.width, height: characterSize.height, parentView: controller.view, gapSize: GAP_SIZE)
    
    // Mode change buttons
    let unshiftKey = Key(type: .modeChange, keyValue: specialKey.ABC, width: shiftDeleteSize.width, height: shiftDeleteSize.height, parentView: controller.view, tag: MODE_CHANGE_ID.unshift, gapSize: GAP_SIZE)
    let shiftKey = Key(type: .modeChange, keyValue: shiftIcon, width: shiftDeleteSize.width, height: shiftDeleteSize.height, parentView: controller.view, tag: MODE_CHANGE_ID.shift, gapSize: GAP_SIZE)
    let symKey = Key(type: .modeChange, keyValue: specialKey.sym, width: characterSize.width, height: characterSize.height, parentView: controller.view, tag: MODE_CHANGE_ID.sym, gapSize: GAP_SIZE)
    let numKey = Key(type: .modeChange, keyValue: specialKey.num, width: shiftDeleteSize.width, height: characterSize.height, parentView: controller.view, tag: MODE_CHANGE_ID.num, gapSize: GAP_SIZE)

    
    //============================================//
    // UNSHIFT PAGE
    //============================================//
    // First Row
    var firstRow = keyboardLayout[MODE_CHANGE_ID.unshift]?.keyboard[0]
    var subscriptFirstRow = keyboardLayout[MODE_CHANGE_ID.shift]?.keyboard[0]
    
    var firstRowKeys : [Key] = []
    // Create keys
    for i in 0..<firstRow!.count {
        let currKey = charKey.copy(keyValue: firstRow?[i])
        currKey.button.isFirstRow = true
        // Add preview subscript to the unshift page.
        currKey.addSubscript(subScript: (subscriptFirstRow?[i])!, isIPad: isIPad)
        firstRowKeys.append(currKey)
    }
    // Add constraints for first row
    for (i,_) in firstRowKeys.enumerated() {
        firstRowKeys[i].button.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: GAP_HEIGHT).isActive = true
        // Top left
        if i == 0 {
            firstRowKeys[i].button.leftAnchor.constraint(equalTo: controller.view.leftAnchor, constant: GAP_WIDTH).isActive = true
        } else {
            firstRowKeys[i].button.leftAnchor.constraint(equalTo: firstRowKeys[i-1].button.rightAnchor, constant: GAP_WIDTH).isActive = true
        }
    }
    
    // Second Row
    var secondRow = keyboardLayout[MODE_CHANGE_ID.unshift]?.keyboard[1]
    var subscriptSecondRow = keyboardLayout[MODE_CHANGE_ID.shift]?.keyboard[1]
    
    var secondRowKeys : [Key] = []
    // Create keys
    for i in 0..<secondRow!.count {
        let currKey = charKey2Row.copy(keyValue: secondRow?[i])
        // Add preview subscript to the unshift page.
        currKey.addSubscript(subScript: (subscriptSecondRow?[i])!, isIPad: isIPad)
        secondRowKeys.append(currKey)
    }
    // Add Padding before Second Row
    // Padding left
    let secondRowGapCount = secondRowKeys.count
    let paddingLeft = (viewWidth - characterSize.width * CGFloat((secondRow?.count)!) - GAP_WIDTH * CGFloat(secondRowGapCount))/2.5
    // Add constraints for second row
    for (i,_) in secondRowKeys.enumerated() {
        secondRowKeys[i].button.topAnchor.constraint(equalTo: firstRowKeys[0].button.bottomAnchor, constant: GAP_HEIGHT).isActive = true
        
        // Leftmostkey
        if i == 0 {
            secondRowKeys[i].button.leftAnchor.constraint(equalTo: controller.view.leftAnchor, constant: paddingLeft).isActive = true
        } else {
            secondRowKeys[i].button.leftAnchor.constraint(equalTo: secondRowKeys[i-1].button.rightAnchor, constant: GAP_WIDTH).isActive = true
        }
    }
    
    // Third Row
    var thirdRow = keyboardLayout[MODE_CHANGE_ID.unshift]?.keyboard[2]
    var subscriptThirdRow = keyboardLayout[MODE_CHANGE_ID.shift]?.keyboard[2]
    
    var thirdRowKeys : [Key] = []
    // Create keys
    for i in 0..<thirdRow!.count {
        var currKey = Key()
        if thirdRow?[i] == specialKey.shift {
            // Shift
            currKey = shiftKey.copy()
        } else if thirdRow?[i] == specialKey.backspace {
            // Backspace
            currKey = backspaceKey.copy()
        }else {
            currKey = charKey.copy(keyValue: thirdRow?[i])
            // Add preview subscript to the unshift page.
            currKey.addSubscript(subScript: (subscriptThirdRow?[i])!, isIPad: isIPad)
        }
        thirdRowKeys.append(currKey)
    }
    // Add constraints for third row
    for (i,_) in thirdRowKeys.enumerated() {
        thirdRowKeys[i].button.topAnchor.constraint(equalTo: secondRowKeys[0].button.bottomAnchor, constant: GAP_HEIGHT).isActive = true
        // Left
        if i == 0 {
            thirdRowKeys[i].button.leftAnchor.constraint(equalTo: controller.view.leftAnchor, constant: GAP_WIDTH).isActive = true
        } else {
            thirdRowKeys[i].button.leftAnchor.constraint(equalTo: thirdRowKeys[i-1].button.rightAnchor, constant: GAP_WIDTH).isActive = true
        }
    }
    
    // Last Row
    var lastRowKeys : [Key] = []
    // Change to number button
    lastRowKeys.append(numKey.copy())
    // Change keyboard button
    lastRowKeys.append(changeKeyboardKey.copy())
    // Spacebar button
    lastRowKeys.append(charKey.copy(type: .space, keyValue: " ", width: spacebarSize.width))
    // Period button
    lastRowKeys.append(charKey.copy(keyValue: "."))
    // Return button
    lastRowKeys.append(enterKey.copy())
    // Add constraints for Last row
    for (i,_) in lastRowKeys.enumerated() {
        lastRowKeys[i].button.topAnchor.constraint(equalTo: thirdRowKeys[0].button.bottomAnchor, constant: GAP_HEIGHT).isActive = true
        
        // Top left
        if i == 0 {
            lastRowKeys[i].button.leftAnchor.constraint(equalTo: controller.view.leftAnchor, constant: GAP_WIDTH).isActive = true
        } else {
            lastRowKeys[i].button.leftAnchor.constraint(equalTo: lastRowKeys[i-1].button.rightAnchor, constant: GAP_WIDTH).isActive = true
        }
    }
    
    // Add the keys to the keybaord with their associated state
    keyboard.keys[MODE_CHANGE_ID.unshift] = []
    keyboard.keys[MODE_CHANGE_ID.unshift]?.append(firstRowKeys)
    keyboard.keys[MODE_CHANGE_ID.unshift]?.append(secondRowKeys)
    keyboard.keys[MODE_CHANGE_ID.unshift]?.append(thirdRowKeys)
    keyboard.keys[MODE_CHANGE_ID.unshift]?.append(lastRowKeys)
 
    //============================================//
    // SHIFTPAGE
    //============================================//
    // Shift Page
    firstRow = keyboardLayout[MODE_CHANGE_ID.shift]?.keyboard[0]
    firstRowKeys = []
    // First Row
    for currChar in firstRow! {
        let currKey = charKey.copy(keyValue: currChar)
        currKey.button.isFirstRow = true
        firstRowKeys.append(currKey)
    }
    // Add constraints for first row
    for (i,_) in firstRowKeys.enumerated() {
        firstRowKeys[i].button.topAnchor.constraint(equalTo:  topBar.bottomAnchor, constant: GAP_HEIGHT).isActive = true
        
        // Top left
        if i == 0 {
            firstRowKeys[i].button.leftAnchor.constraint(equalTo: controller.view.leftAnchor, constant: GAP_WIDTH).isActive = true
        } else {
            firstRowKeys[i].button.leftAnchor.constraint(equalTo: firstRowKeys[i-1].button.rightAnchor, constant: GAP_WIDTH).isActive = true
        }
    }
    
    // Second Row
    secondRow = keyboardLayout[MODE_CHANGE_ID.shift]?.keyboard[1]
    secondRowKeys = []
    // Add Padding before Second Row
    for currChar in secondRow! {
        let currKey = charKey.copy(keyValue: currChar)
        secondRowKeys.append(currKey)
    }
    // Add constraints for second row
    for (i,_) in secondRowKeys.enumerated() {
        secondRowKeys[i].button.topAnchor.constraint(equalTo: firstRowKeys[0].button.bottomAnchor, constant: GAP_HEIGHT).isActive = true
        
        // Top left
        if i == 0 {
            secondRowKeys[i].button.leftAnchor.constraint(equalTo: controller.view.leftAnchor, constant: paddingLeft).isActive = true
        } else {
            secondRowKeys[i].button.leftAnchor.constraint(equalTo: secondRowKeys[i-1].button.rightAnchor, constant: GAP_WIDTH).isActive = true
        }
    }
    
    // Third Row
    thirdRow = keyboardLayout[MODE_CHANGE_ID.shift]?.keyboard[2]
    thirdRowKeys = []
    // Shift key
    thirdRowKeys.append(unshiftKey.copy())
    // Keys between shift and backspace
    for i in 1...(thirdRow!.count - 2) {
        let currKey = charKey.copy(keyValue: thirdRow?[i])
        thirdRowKeys.append(currKey)
    }
    // Backspace key
    thirdRowKeys.append(backspaceKey.copy())
    // Add constraints for third row
    for (i,_) in thirdRowKeys.enumerated() {
        thirdRowKeys[i].button.topAnchor.constraint(equalTo: secondRowKeys[0].button.bottomAnchor, constant: GAP_HEIGHT).isActive = true
        
        // Left
        if i == 0 {
            thirdRowKeys[i].button.leftAnchor.constraint(equalTo: controller.view.leftAnchor, constant: GAP_WIDTH).isActive = true
        } else {
            thirdRowKeys[i].button.leftAnchor.constraint(equalTo: thirdRowKeys[i-1].button.rightAnchor, constant: GAP_WIDTH).isActive = true
        }
    }
    
    // Last Row
    lastRowKeys = []
    // Change to number button
    lastRowKeys.append(numKey.copy())
    // Change keyboard button
    lastRowKeys.append(changeKeyboardKey.copy())
    // Spacebar button
    lastRowKeys.append(charKey.copy(type: .space, keyValue: " ", width: spacebarSize.width))
    // Period button
    lastRowKeys.append(charKey.copy(keyValue: "?"))
    // Return button
    lastRowKeys.append(enterKey.copy())
    
    // Add constraints for third row
    for (i,_) in lastRowKeys.enumerated() {
        lastRowKeys[i].button.topAnchor.constraint(equalTo: thirdRowKeys[0].button.bottomAnchor, constant: GAP_HEIGHT).isActive = true
        
        // Top left
        if i == 0 {
            lastRowKeys[i].button.leftAnchor.constraint(equalTo: controller.view.leftAnchor, constant: GAP_WIDTH).isActive = true
        } else {
            lastRowKeys[i].button.leftAnchor.constraint(equalTo: lastRowKeys[i-1].button.rightAnchor, constant: GAP_WIDTH).isActive = true
        }
    }
    
    keyboard.keys[MODE_CHANGE_ID.shift]?.append(firstRowKeys)
    keyboard.keys[MODE_CHANGE_ID.shift]?.append(secondRowKeys)
    keyboard.keys[MODE_CHANGE_ID.shift]?.append(thirdRowKeys)
    keyboard.keys[MODE_CHANGE_ID.shift]?.append(lastRowKeys)
    
    //============================================//
    // 123 PAGE
    //============================================//
    firstRow = keyboardLayout[MODE_CHANGE_ID.num]?.keyboard[0]
    firstRowKeys = []
//    // First Row
    for currChar in firstRow! {
        let currKey = charKey.copy(keyValue: currChar)
        currKey.button.isFirstRow = true
        firstRowKeys.append(currKey)
    }
    // Add constraints for first row
    for (i,_) in firstRowKeys.enumerated() {
        firstRowKeys[i].button.topAnchor.constraint(equalTo:  topBar.bottomAnchor, constant: GAP_HEIGHT).isActive = true
        
        // Top left
        if i == 0 {
            firstRowKeys[i].button.leftAnchor.constraint(equalTo: controller.view.leftAnchor, constant: GAP_WIDTH).isActive = true
        } else {
            firstRowKeys[i].button.leftAnchor.constraint(equalTo: firstRowKeys[i-1].button.rightAnchor, constant: GAP_WIDTH).isActive = true
        }
    }
    
    // Second Row
    secondRow = keyboardLayout[MODE_CHANGE_ID.num]?.keyboard[1]
    secondRowKeys = []
    // Add Padding before Second Row
    for currChar in secondRow! {
        let currKey = charKey.copy(keyValue: currChar)
        secondRowKeys.append(currKey)
    }
    // Add constraints for second row
    for (i,_) in secondRowKeys.enumerated() {
        secondRowKeys[i].button.topAnchor.constraint(equalTo: firstRowKeys[0].button.bottomAnchor, constant: GAP_HEIGHT).isActive = true
        
        // Second row padding
        if i == 0 {
//            secondRowKeys[i].button.leftAnchor.constraint(equalTo: controller.view.leftAnchor, constant: paddingLeft).isActive = true
            secondRowKeys[i].button.leftAnchor.constraint(equalTo: controller.view.leftAnchor, constant: GAP_WIDTH).isActive = true
        } else {
            secondRowKeys[i].button.leftAnchor.constraint(equalTo: secondRowKeys[i-1].button.rightAnchor, constant: GAP_WIDTH).isActive = true
        }
    }
//    
//    // Third Row
    thirdRow = keyboardLayout[MODE_CHANGE_ID.num]?.keyboard[2]
    thirdRowKeys = []
    // Sym key
    thirdRowKeys.append(symKey.copy(width:shiftDeleteSize.width, height:shiftDeleteSize.height))
    // Keys between sym and backspace
    for i in 1...(thirdRow!.count - 2) {
        let currKey = charKey.copy(keyValue: thirdRow?[i])
        thirdRowKeys.append(currKey)
    }
    // Backspace key
    thirdRowKeys.append(backspaceKey.copy())
    // Add constraints for third row
    for (i,_) in thirdRowKeys.enumerated() {
        thirdRowKeys[i].button.topAnchor.constraint(equalTo: secondRowKeys[0].button.bottomAnchor, constant: GAP_HEIGHT).isActive = true
        
        // Left
        if i == 0 {
            thirdRowKeys[i].button.leftAnchor.constraint(equalTo: controller.view.leftAnchor, constant: GAP_WIDTH).isActive = true
        }
        else if i == 7{
            thirdRowKeys[i].button.rightAnchor.constraint(equalTo: controller.view.rightAnchor, constant: -GAP_WIDTH).isActive = true
        }
        else {
            thirdRowKeys[i].button.leftAnchor.constraint(equalTo: thirdRowKeys[i-1].button.rightAnchor, constant: GAP_WIDTH).isActive = true
        }
    }
    
    // Last Row
    lastRowKeys = []
    // Change to number button
    lastRowKeys.append(unshiftKey.copy())
    // Change keyboard button
    lastRowKeys.append(changeKeyboardKey.copy())
    // Spacebar button
    lastRowKeys.append(charKey.copy(type: .space, keyValue: " ", width: spacebarSize.width))
    // Comma button
    lastRowKeys.append(charKey.copy(keyValue: ","))
    // Return button
    lastRowKeys.append(enterKey.copy())
    
    // Add constraints for third row
    for (i,_) in lastRowKeys.enumerated() {
        lastRowKeys[i].button.topAnchor.constraint(equalTo: thirdRowKeys[0].button.bottomAnchor, constant: GAP_HEIGHT).isActive = true
        
        // Top left
        if i == 0 {
            lastRowKeys[i].button.leftAnchor.constraint(equalTo: controller.view.leftAnchor, constant: GAP_WIDTH).isActive = true
        } else {
            lastRowKeys[i].button.leftAnchor.constraint(equalTo: lastRowKeys[i-1].button.rightAnchor, constant: GAP_WIDTH).isActive = true
        }
    }
    
    keyboard.keys[MODE_CHANGE_ID.num]?.append(firstRowKeys)
    keyboard.keys[MODE_CHANGE_ID.num]?.append(secondRowKeys)
    keyboard.keys[MODE_CHANGE_ID.num]?.append(thirdRowKeys)
    keyboard.keys[MODE_CHANGE_ID.num]?.append(lastRowKeys)
    
    
    //============================================//
    // SYM PAGE
    //============================================//
    firstRow = keyboardLayout[MODE_CHANGE_ID.sym]?.keyboard[0]
    firstRowKeys = []
    //    // First Row
    for currChar in firstRow! {
        let currKey = charKey.copy(keyValue: currChar)
        currKey.button.isFirstRow = true
        firstRowKeys.append(currKey)
    }
    // Add constraints for first row
    for (i,_) in firstRowKeys.enumerated() {
        firstRowKeys[i].button.topAnchor.constraint(equalTo:  topBar.bottomAnchor, constant: GAP_HEIGHT).isActive = true
        
        // Top left
        if i == 0 {
            firstRowKeys[i].button.leftAnchor.constraint(equalTo: controller.view.leftAnchor, constant: GAP_WIDTH).isActive = true
        } else {
            firstRowKeys[i].button.leftAnchor.constraint(equalTo: firstRowKeys[i-1].button.rightAnchor, constant: GAP_WIDTH).isActive = true
        }
    }
    
    // Second Row
    secondRow = keyboardLayout[MODE_CHANGE_ID.sym]?.keyboard[1]
    secondRowKeys = []
    // Add Padding before Second Row
    for currChar in secondRow! {
        let currKey = charKey.copy(keyValue: currChar)
        secondRowKeys.append(currKey)
    }
    // Add constraints for second row
    for (i,_) in secondRowKeys.enumerated() {
        secondRowKeys[i].button.topAnchor.constraint(equalTo: firstRowKeys[0].button.bottomAnchor, constant: GAP_HEIGHT).isActive = true
        
        // Top left
        if i == 0 {
            secondRowKeys[i].button.leftAnchor.constraint(equalTo: controller.view.leftAnchor, constant: GAP_WIDTH).isActive = true
        } else {
            secondRowKeys[i].button.leftAnchor.constraint(equalTo: secondRowKeys[i-1].button.rightAnchor, constant: GAP_WIDTH).isActive = true
        }
    }
    
    // Third Row
    thirdRow = keyboardLayout[MODE_CHANGE_ID.sym]?.keyboard[2]
    thirdRowKeys = []
    // SYM key
    thirdRowKeys.append(numKey.copy(width:shiftDeleteSize.width, height: shiftDeleteSize.height))
    // Keys between sym and backspace
    for i in 1...(thirdRow!.count - 2) {
        let currKey = charKey.copy(keyValue: thirdRow?[i])
        thirdRowKeys.append(currKey)
    }
    // Backspace key
    thirdRowKeys.append(backspaceKey.copy())
    // Add constraints for third row.
    for (i,_) in thirdRowKeys.enumerated() {
        thirdRowKeys[i].button.topAnchor.constraint(equalTo: secondRowKeys[0].button.bottomAnchor, constant: GAP_HEIGHT).isActive = true
        
        // Left
        if i == 0 {
            thirdRowKeys[i].button.leftAnchor.constraint(equalTo: controller.view.leftAnchor, constant: GAP_WIDTH).isActive = true
        }
        else if i == 7{
            thirdRowKeys[i].button.rightAnchor.constraint(equalTo: controller.view.rightAnchor, constant: -GAP_WIDTH).isActive = true
        }
        else {
            thirdRowKeys[i].button.leftAnchor.constraint(equalTo: thirdRowKeys[i-1].button.rightAnchor, constant: GAP_WIDTH).isActive = true
        }
    }
    
    // Last Row
    lastRowKeys = []
    // Change to number button
    lastRowKeys.append(unshiftKey.copy())
    // Change keyboard button
    lastRowKeys.append(changeKeyboardKey.copy())
    // Spacebar button
    lastRowKeys.append(charKey.copy(type: .space, keyValue: " ", width: spacebarSize.width))
    // BulletPoint button
    lastRowKeys.append(charKey.copy(keyValue: "•"))
    // Return button
    lastRowKeys.append(enterKey.copy())
    // Add constraints for Last row
    for (i,_) in lastRowKeys.enumerated() {
        lastRowKeys[i].button.topAnchor.constraint(equalTo: thirdRowKeys[0].button.bottomAnchor, constant: GAP_HEIGHT).isActive = true
        
        // Top left
        if i == 0 {
            lastRowKeys[i].button.leftAnchor.constraint(equalTo: controller.view.leftAnchor, constant: GAP_WIDTH).isActive = true
        } else {
            lastRowKeys[i].button.leftAnchor.constraint(equalTo: lastRowKeys[i-1].button.rightAnchor, constant: GAP_WIDTH).isActive = true
        }
    }
    
    keyboard.keys[MODE_CHANGE_ID.sym]?.append(firstRowKeys)
    keyboard.keys[MODE_CHANGE_ID.sym]?.append(secondRowKeys)
    keyboard.keys[MODE_CHANGE_ID.sym]?.append(thirdRowKeys)
    keyboard.keys[MODE_CHANGE_ID.sym]?.append(lastRowKeys)
        
    return keyboard
}

struct Root : Decodable {
    private enum CodingKeys : String, CodingKey {
        case r = "r"
        case serverBuild = "serverBuild"
        case staleClient = "staleClient"
        case  w = "w"
    }
    
    let r : String
    let serverBuild : String
    let staleClient : Bool
    let w : String
}

