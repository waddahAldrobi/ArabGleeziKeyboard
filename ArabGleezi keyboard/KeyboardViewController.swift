//
//  KeyboardViewController.swift
//  lisu keyboard
//
//  Created by Amos Gwa on 12/21/16.
//  Copyright © 2016 Amos Gwa. All rights reserved.
//

import UIKit
import Foundation

// Extension for the UILabel to change font size.
extension UILabel {
    func setSizeFont (sizeFont: CGFloat) {
        self.font =  UIFont(name: self.font.fontName, size: sizeFont)!
        self.sizeToFit()
    }
}

class KeyboardViewController: UIInputViewController {
    
    @IBOutlet var nextKeyboardButton: UIButton!
    var backspaceButtonTimer: Timer? = nil
    var thresholdTimer: Timer? = nil
    
    // Custom height for keyboard
    var heightConstraint:NSLayoutConstraint? = nil
    
    // viewWidth and viewHeight of the keyboard view
    var viewWidth: CGFloat = 0
    var viewHeight: CGFloat = 0
    
    var portraitSize: CGSize = CGSize(width: 0, height: 0)
    var landscapeSize: CGSize = CGSize(width: 0, height: 0)
    
    // Check if the device is in portrait mode initially.
    var isPortrait = UIScreen.main.bounds.height > UIScreen.main.bounds.width
    
    // Check the device type
    let isIPad = UIDevice.current.userInterfaceIdiom == .pad
    
    // Current popup view.
    var currPopup : [UIView] = []
    
    // darkened keys needs to be whitened.
    var pressedCharacterKeys : [UIButton] = []
    var pressedSpecialKeys : [UIButton] = []
    
    // Keyborard current page : unshift, shift, 123
    var currPage = MODE_CHANGE_ID.unshift
    var keyboard : Keyboard = Keyboard()
    
    // Set the top bar Height
    var topBarHeight : CGFloat = 0
    
    // Delete key
    var deleteKey : UIButton? = nil
    let feedbackButton = UIBarButtonItem()
    
     let topBar = UIToolbar()
    override func viewWillAppear(_ animated: Bool) {
        self.renderKeys()
//        self.calc_customWidthHeight()
        self.view.backgroundColor = theme.keyboardBackgroundColor
        self.togglePageView(currPage: 0, newPage: self.currPage)
        
        super.viewWillAppear(animated)
        // Apply background style
        
        self.primaryLanguage = "ar"
        
        let barHeight = isIPad ? 0 : self.viewHeight * 0.15
        
        feedbackButton.title = "Arab"
        
        feedbackButton.tintColor = .gray
        feedbackButton.target = self
        feedbackButton.action = #selector(self.wordPressedOnce(sender:))
        
        topBar.items = [feedbackButton]
        self.view.addSubview(topBar)
        topBar.widthAnchor.constraint(equalToConstant: viewWidth).isActive = true
        topBar.heightAnchor.constraint(equalToConstant: barHeight).isActive = true
        topBar.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        topBar.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        topBar.translatesAutoresizingMaskIntoConstraints = false
        topBar.backgroundColor = theme.keyboardBackgroundColor

      
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.calc_customWidthHeight()
    }
  
    // Calculate the width and height of the keyboard based on the initial orientation of the device.
    func calc_customWidthHeight(){
        
        // I had to add top bar high at the end. Since the pop up key has to go beyond the keyboard. It's 15% increase.
        // Only applies to iPhones
        let topBarIncRatio : CGFloat = self.isIPad ? 1 : 1.15
      
        if isPortrait {
            portraitSize.width = UIScreen.main.bounds.width
            portraitSize.height = round(UIScreen.main.bounds.height * 0.32 * topBarIncRatio)
            
            viewWidth = portraitSize.width
            viewHeight = portraitSize.height
          
            landscapeSize.height = round(UIScreen.main.bounds.width * 0.43 * topBarIncRatio)
            landscapeSize.width = UIScreen.main.bounds.height
        } else {
            landscapeSize.width = UIScreen.main.bounds.width
            landscapeSize.height = round(UIScreen.main.bounds.height * 0.43 * topBarIncRatio)
            
            viewWidth = landscapeSize.width
            viewHeight = landscapeSize.height
          
            portraitSize.height = round(UIScreen.main.bounds.width * 0.32 * topBarIncRatio)
            portraitSize.width = UIScreen.main.bounds.height
        }
    }
  
    // Set the width and height of the keyboard
    func set_customWidthHeight() {
      if heightConstraint == nil {
        heightConstraint = NSLayoutConstraint(item: self.view,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: viewHeight)
        heightConstraint?.priority = UILayoutPriority(UILayoutPriorityRequired)
        self.view.addConstraint(heightConstraint!)
      } else {
        heightConstraint?.constant = viewHeight
      }
    }
  
//    override func viewDidAppear(_ animated: Bool) {
//      super.viewDidAppear(animated)
//      
//      
//    }
//  
    override func updateViewConstraints() {
        super.updateViewConstraints()
        // Change the view constraint to custom.
        self.set_customWidthHeight()
    }
  
    // When changing orientation, change the keyboard height and width
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // Check if the orientation has definitely changed from landscape to portrait or viceversa.
        // This is to prevent flipping landscapes. The device will rotate with the same width.
      
        if size.width != viewWidth {
            
            isPortrait = !isPortrait
            
            if isPortrait {
                viewHeight = portraitSize.height
                viewWidth = portraitSize.width
            } else {
                viewHeight = landscapeSize.height
                viewWidth = landscapeSize.width

//                viewWidth = landscapeSize.width - (landscapeSize.width*0.2678)
//                if landscapeSize.width > 736 {
//                    viewWidth = landscapeSize.width - 140
//                } else if landscapeSize.width > 812 {
//                    viewWidth = landscapeSize.width - 240
//                }
                
//                textDocumentProxy.insertText(String(Float(viewWidth))
//                print(landscapeSize.width)
            }
            
            coordinator.animateAlongsideTransition(in: self.view, animation: {(_ context: UIViewControllerTransitionCoordinatorContext) -> Void in
                self.renderKeys()
                // Display the currPage
                self.togglePageView(currPage: 0, newPage: self.currPage)
            }, completion: {(_ context: UIViewControllerTransitionCoordinatorContext) -> Void in
                //Done animation
            })
        }
      
    }
    
    // Remove key from the sub view.
    func removeAllSubView() {
        for v in self.view.subviews{
            v.removeFromSuperview()
        }
    }
    
    // Render Keys
    func renderKeys() {
        
        // Remove all of the existing keys before rendering
        self.removeAllSubView()
        
        // Set up a keyboard with the custom width and height
        keyboard = lisuKeyboardLayout(controller: self, totalWidth: self.viewWidth, totalHeight: self.viewHeight, isPortrait: self.isPortrait, isIPad: self.isIPad)
        
        // Add all the keys to the View
        for currKeyboard in keyboard.keys.values {
            for row in currKeyboard {
                for key in row {
                    self.view.addSubview(key.button)
                }
            }
        }
        
        // Extract out some keys.
        self.deleteKey = self.view.viewWithTag(MODE_CHANGE_ID.del) as? UIButton
        
        // Add listeners to the keys
        self.addEventListeners()
    }
    
    // Add event listeners to the keys.
    func addEventListeners() {
        for currKeyboard in keyboard.keys.values {
            for row in currKeyboard {
                for key in row {
                    if key.type == .character {
                        // Characters to be typed
                        key.button.addTarget(self, action: #selector(self.keyPressedOnce(sender:)), for: [.touchUpInside, .touchUpOutside])
                        key.button.addTarget(self, action: #selector(self.keyPressedHold(sender:)), for: .touchDown)
                    } else if key.type == .space {
                        // Listener for spacebar
                        key.button.addTarget(self, action: #selector(self.spacePressedOnce(sender:)), for: [.touchUpInside, .touchUpOutside])
                        key.button.addTarget(self, action: #selector(self.spacePressedHold(sender:)), for: .touchDown)
                    } else if key.type == .keyboardChange {
                        // Changing keyboard
                        // right here
                        self.nextKeyboardButton = key.button
                      if #available(iOSApplicationExtension 10.0, *) {
                        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
                      } else {
                        // Fallback on earlier versions
                        self.nextKeyboardButton.addTarget(self, action: #selector(advanceToNextInputMode), for: .allTouchEvents)
                      }
                    } else if key.type == .modeChange {
                        // Chaning modes
                        key.button.addTarget(self, action: #selector(self.modeChangePressedOnce(sender:)), for: [.touchUpInside, .touchUpOutside])
                        key.button.addTarget(self, action: #selector(self.modeChangePressedHold(sender:)), for: .touchDown)
                    } else if key.type == .backspace {
                        // Deleting characters
                        let deleteButtonLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(KeyboardViewController.backspacePressedLong(gestureRecognizer:)))
                        deleteButtonLongPressGestureRecognizer.minimumPressDuration = 0.5
                        key.button.addGestureRecognizer(deleteButtonLongPressGestureRecognizer)
                        key.button.addTarget(self, action: #selector(self.backspacePressedOnce(sender:)), for: [.touchUpInside, .touchUpOutside])
                        key.button.addTarget(self, action: #selector(self.backspacePressed(sender:)), for: .touchDown)
                    } else if key.type == .enter {
                        // Enter(Return) key
                        // Update the key value based on the returnType
                        key.button.addTarget(self, action: #selector(self.returnPressedOnce(sender:)), for: [.touchUpInside, .touchUpOutside])
                        key.button.addTarget(self, action: #selector(self.returnPressedHold(sender:)), for: .touchDown)
                    }
                }
            }
        }
    }
    
    // Return button is pressed.
    func returnPressedOnce(sender: UIButton) {
        self.releasedSpecialKey(sender: sender)
        self.textDocumentProxy.insertText("\n")
    }
    
    func returnPressedHold(sender: UIButton) {
        self.pressedSpecialKey(sender: sender)
    }
    
    // Mode change is pressed.
    func modeChangePressedOnce(sender: UIButton){
        self.releasedSpecialKey(sender: sender)
        togglePageView(currPage: currPage, newPage: sender.tag)
    }
    
    func modeChangePressedHold(sender: UIButton) {
        self.pressedSpecialKey(sender: sender)
    }
    
    // Attempt to optimize stage change
    // Toggle pages for the button
    func togglePageView(currPage: Int, newPage: Int) {
        // Hide the current
        if currPage != 0 {
            for row in keyboard.keys[currPage]! {
                for key in row {
                    key.button.isHidden = true
                }
            }
        }
    
        // Show the next
        if newPage != 0 {
            for row in keyboard.keys[newPage]! {
                for key in row {
                    key.button.isHidden = false
                }
            }
        }
        
        // Update the currPage
        self.currPage = newPage
    }
    
    // Trigger for delete on hold and press once.
    func backspacePressedOnce(sender: UIButton) {
        self.releasedSpecialKey(sender: sender)
        self.backspaceButtonTimer?.invalidate()
        //self.backspaceDelete()
    }
    
    func backspacePressed(sender: UIButton) {
        self.backspaceDelete()
        self.pressedSpecialKey(sender: sender)
    }
    
    func backspacePressedLong(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            if backspaceButtonTimer == nil {
                // Fast deleting here
                backspaceButtonTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(KeyboardViewController.backspaceDelete), userInfo: nil, repeats: true)
                backspaceButtonTimer!.tolerance = 0.01
            }
        }
        else if gestureRecognizer.state == UIGestureRecognizerState.ended {
            
            // Release the key
            self.releasedSpecialKey(sender: gestureRecognizer.view as! UIButton)
            
            backspaceButtonTimer?.invalidate()
            backspaceButtonTimer = nil
        }
    }
    
    func backspaceDelete() {
        self.textDocumentProxy.deleteBackward()
        lastChar = ""
        
        if sG.count != 0 { sG.removeLast() }
        feedbackButton.title = lastWordTyped
        
        if Reachability.isConnectedToNetwork() && hasAccess {
            //Problem
            if lastWordTyped != "" && lastWordTyped != " " && lastWordTyped != nil {
            getString( word: lastWordTyped!, withCompletion: { newWord in
                    DispatchQueue.main.sync {
                        self.feedbackButton.title = newWord as? String
                        var suggestionsListStr = (newWord as? String)?.characters.split{$0 == ","}.map(String.init)
                        var listBtn = [UIBarButtonItem]()
                        
                        for i in suggestionsListStr! {
                            let btn = UIBarButtonItem()
                            btn.title = i
                            btn.action = #selector(self.wordPressedOnce(sender:))
                            listBtn.append(btn)
                        }

                        // Needs refactoring
                        let btn = UIBarButtonItem()
                        btn.title = self.lastWordTyped
                        btn.action = #selector(self.wordPressedOnce(sender:))
                        listBtn.append(btn)
                        
//                        let btn2 = UIBarButtonItem()
//                        btn2.title = String(self.lastSentenceLen)
//                        listBtn.append(btn2)
                        
                        self.topBar.items = listBtn
                        
                    }
                })
            }
            else {self.topBar.items = nil}
        }
    }
    
    // Triger for spacebar press.
    func spacePressedOnce(sender: UIButton) {
        self.whitenKey(sender: sender)
        
        // Autoperiod
        if lastChar != " "{
            self.textDocumentProxy.insertText((sender.titleLabel?.text)!)
            lastChar = " "
        }
        else {
            self.textDocumentProxy.deleteBackward()
            self.textDocumentProxy.insertText(".")
            self.textDocumentProxy.insertText((sender.titleLabel?.text)!)
            lastChar = ""
        }
    
        
        feedbackButton.title = lastWordTyped
        sG.append((sender.titleLabel?.text)!)
    }
    
    func spacePressedHold(sender: UIButton) {
        self.darkenKey(sender: sender)
    }
    
    // Trigger for character key press.
    func keyPressedHold(sender: keyButton){
        if isIPad {
            self.darkenKey(sender: sender)
        } else {
            self.showKeyPopUp(sender: sender)
        }
    }
    
    var lastChar = ""
    var sG = ""
    
    func keyPressedOnce(sender: UIButton) {
        // Remove the popup keys
        if isIPad {
            self.whitenKey(sender: sender)
        } else {
            self.removePopUpKeys()
        }
        
        let key = sender.titleLabel?.text!.uppercased()
        
        //self.showKeyPopUp(sender: sender)
        if sender.titleLabel?.text == "ـً‎"{
            self.textDocumentProxy.insertText("ً")
        }
        else{
            self.textDocumentProxy.insertText(translate(letter: (sender.titleLabel?.text!.uppercased())!, prevChar: lastChar))
            sG.append((sender.titleLabel?.text!.lowercased())!)
            
            lastChar = mappings[(sender.titleLabel?.text!.uppercased())!, default:key!]
        }
     
        
        // Return to unshift page if the currPage is shift.
        if currPage == MODE_CHANGE_ID.shift {
            togglePageView(currPage: self.currPage, newPage: MODE_CHANGE_ID.unshift)
        }
        
        
        
        // Here
        var listBtn = [UIBarButtonItem]()
        
         if Reachability.isConnectedToNetwork() && hasAccess{
            if !breakChar.contains((sender.titleLabel?.text!)!) {
                
            getString( word: lastWordTyped!, withCompletion: { newWord in
                DispatchQueue.main.sync {
                        self.feedbackButton.title = newWord as? String
                        var suggestionsListStr = (newWord as? String)?.characters.split{$0 == ","}.map(String.init)
                    
                    
                        var k = 0
                        for i in suggestionsListStr! {
                            let btn = UIBarButtonItem()
                            btn.title = i
                            btn.action = #selector(self.wordPressedOnce(sender:))
                            listBtn.append(btn)
                            
                            k = k+1
                            if k == 4{
                                break
                            }
                        }
                    
                        // Needs refactoring
                        let btn = UIBarButtonItem()
                        btn.title = self.lastWordTyped
                        btn.action = #selector(self.wordPressedOnce(sender:))
                        listBtn.append(btn)
//                    https://stackoverflow.com/questions/39676939/how-does-string-index-work-in-swift
//                        let btn2 = UIBarButtonItem()
////                        btn2.title = String(self.sG.endIndex.encodedOffset)
//                        btn2.title = String((self.textDocumentProxy.documentContextBeforeInput as! String).endIndex.encodedOffset)
//                        listBtn.append(btn2)
                    
//                        var t = (self.textDocumentProxy.documentContextBeforeInput as! String)
//                        // range
//                        let range = self.sG.startIndex..<t.index(before: t.endIndex)
//                        let button = UIBarButtonItem()
//                        button.title = self.sG[range]
//                        listBtn.append(button)
                    
                        self.topBar.items = listBtn
                }
            })
                // Needs refactoring
                getHarakatWord( word: lastWordTyped!, withCompletion: { a in
                    
                    DispatchQueue.main.sync {
                        let btn = UIBarButtonItem()
                        btn.title = (a as! String)
                        btn.title?.dropLast()
                        btn.action = #selector(self.wordPressedOnce(sender:))
                        listBtn.append(btn)
                        
                        self.topBar.items = listBtn
                    }
                })
                
            }
        }
    }
    
    // Returns message arabeezi
    var lastWordTyped: String? {
        if lastSentenceLen != 0 {
            if let documentContext = sG as String? {
                let length = documentContext.count
                if length > 0 {
                    

                    
                    var components = [String]()
                    
                    
                    
                    components = documentContext.components(separatedBy: characterSet)

                    
                    return components[components.endIndex - 1]
                }
            }
        }
    
        else {
            sG = ""
            return nil
        }
        return nil
    }
    
    // Returns message length
    var lastSentenceLen: Int {
        if let documentContext = self.textDocumentProxy.documentContextBeforeInput as NSString? {
            let length = documentContext.length
            return length
        }
        
        return 0
    }
    
    // Returns if have full access
    var hasAccess: Bool {
        get{
            if #available(iOSApplicationExtension 11.0, *) {
                return self.hasFullAccess
            } else {
                return UIDevice.current.identifierForVendor != nil
            }
        }
    }
    
    // Darken the key on press for chracters.
    func darkenKey(sender: UIButton){
        sender.backgroundColor = theme.keyPressedColor
        self.pressedCharacterKeys.append(sender)
    }
    
    func whitenKey(sender: UIButton) {
        let i = 0
        while self.pressedCharacterKeys.count > 0{
            self.pressedCharacterKeys[i].backgroundColor = theme.keyBackgroundColor
            self.pressedCharacterKeys.remove(at: i)
        }
    }
    
    func pressedSpecialKey(sender: UIButton){
        sender.backgroundColor = theme.keyBackgroundColor
        self.pressedSpecialKeys.append(sender)
    }
    
    func releasedSpecialKey(sender: UIButton) {
        let i = 0
        while self.pressedSpecialKeys.count > 0{
            self.pressedSpecialKeys[i].backgroundColor = theme.specialKeyBackgroundColor
            self.pressedSpecialKeys.remove(at: i)
        }
    }
    
    // Remove the pressed Views.
    func removePopUpKeys() {
        let i = 0
        while self.currPopup.count > 0{
            self.currPopup[i].removeFromSuperview()
            self.currPopup.remove(at: i)
        }
    }
    
    // Show the pop up for characters.
    func showKeyPopUp(sender: keyButton){
        let customView = UIView()
        let keyLabel = UILabel()
        
        keyLabel.setSizeFont(sizeFont: keyLabel.font.pointSize * 1.5)
        
        // Add the preview key label to the popup view.
        customView.addSubview(keyLabel)
        
        // Add constraint to the preview key label.
        keyLabel.widthAnchor.constraint(equalToConstant: sender.frame.size.width).isActive = true
        keyLabel.heightAnchor.constraint(equalToConstant: sender.frame.size.height).isActive = true
        keyLabel.centerXAnchor.constraint(equalTo: customView.centerXAnchor).isActive = true
        keyLabel.topAnchor.constraint(equalTo: customView.topAnchor).isActive = true
        
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        keyLabel.textAlignment = NSTextAlignment.center
        keyLabel.text = (sender.titleLabel?.text)!
        
        // Modify the preview label to center accordingly with the pressed button.
        customView.sizeToFit()
        customView.backgroundColor = UIColor.white
        
        // Add shadow to the button
        customView.layer.masksToBounds = false
        customView.layer.shadowColor = UIColor.darkGray.cgColor
        customView.layer.cornerRadius = 5
        customView.layer.shadowOffset = CGSize(width: 0, height: 0)
        customView.layer.shadowOpacity = 0.7
        customView.layer.shadowRadius = 1.5
        
        self.view.addSubview(customView)
        
        customView.widthAnchor.constraint(equalToConstant: sender.frame.size.width).isActive = true
        
        if sender.isFirstRow {
            customView.heightAnchor.constraint(equalToConstant: sender.frame.size.height * 2.0).isActive = true
        } else {
            customView.heightAnchor.constraint(equalToConstant: sender.frame.size.height * 2.5).isActive = true
        }
        
        customView.translatesAutoresizingMaskIntoConstraints = false
        
        customView.bottomAnchor.constraint(equalTo: sender.bottomAnchor).isActive = true
        customView.leftAnchor.constraint(equalTo: sender.leftAnchor).isActive = true
        
        currPopup.append(customView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
        
    }
    
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        if (self.nextKeyboardButton != nil) {
            self.nextKeyboardButton.setTitleColor(textColor, for: [])
        }
        
        if (proxy.documentContextBeforeInput == nil && proxy.documentContextAfterInput == nil) || ((proxy.documentContextBeforeInput == "") && (proxy.documentContextAfterInput == "")) {
            topBar.items = nil
            sG = ""
        }
    }

    
    // This is for the prediction bar
    func wordPressedOnce(sender: UIBarButtonItem) {
        deleteLastWord()
        self.textDocumentProxy.insertText(sender.title!)
//        self.textDocumentProxy.adjustTextPosition(byCharacterOffset: -1)
    }
    
    // translates
    // Needs refinement, will come back later once figured out the predictive bar
    func translate (letter: String , prevChar: String) -> String {
        
        switch letter {
        // Try to remember why you have those else's maybe it's fixed
        case "H" :
            switch prevChar {
            case "س","c" : self.textDocumentProxy.deleteBackward() ;return "ش"
            case "ط" : self.textDocumentProxy.deleteBackward() ;return "ظ"
            case "ج" : self.textDocumentProxy.deleteBackward() ;return "غ"
            //                    case "ه" : self.textDocumentProxy.deleteBackward() ;return "ة"
            case "ك" : self.textDocumentProxy.deleteBackward() ;return "خ"
                
            default: return "ه" // ## e,ah and eh , maybe a
            }
            
        case "’","'" :
            switch prevChar {
            case "ح" : self.textDocumentProxy.deleteBackward() ;return "خ"
            case "ع" : self.textDocumentProxy.deleteBackward() ;return "غ"
            case "ص" : self.textDocumentProxy.deleteBackward() ;return "ض"
            case "ط" : self.textDocumentProxy.deleteBackward() ;return "ظ"
                
            default: return "'"
            }
            
        case "E" :
            switch prevChar {
            case "ا" , "ي" : self.textDocumentProxy.deleteBackward() ; return "ي"
                
            default: return "ا"
            }
            
            // Case o and u can all be refactored into 1 case, will look into later
        // Not sure if to do this
        case "o","O" :
            switch prevChar {
            // the 3een doesnt seem right
            case "و" : self.textDocumentProxy.deleteBackward() ;return "و"
                
            default: return "و"
            }
            
        case "U" :
            switch prevChar {
            case "و" : self.textDocumentProxy.deleteBackward() ; return "و"
                
            default: return "و"
            }
            
        default: return mappings[letter, default: letter ]
            
        }
    }
    
    func deleteLastWord() {
        // Need to detect the last word edited
        if let textArray:[String]? = self.textDocumentProxy.documentContextBeforeInput?.components(separatedBy: " "){
            if let validArray = textArray{
                for _ in 0 ..< validArray.last!.count {
                    self.textDocumentProxy.deleteBackward()
                }
            }
        }
    }
}



var mappings: [String : String] = [
    /*number*/"2" : "أ",  //also  /*ء أ آ ؤ إ ئ */
    /*number*/"3" : "ع",
    /*number*/"5" : "خ",
    /*number*/"6" : "ط",  //also "t"
    /*number*/"7" : "ح",  //also "h"
    /*number*/"8" : "ق",
              /*number*/"9" : "ص",  //also "s"
    
    "A" : "ا", // a lot more complicated "ꓮ"
    "B" : "ب",
    "D" : "د",
    "E" : "ا" ,
    "F" : "ف",
    "G" : "ج", // "dj"
    
    "I" : "ي", // other letters
    "J" : "ج",
    "K" : "ك", // maybe g
    "L" : "ل",
    "M" : "م",
    "N" : "ن",
    
    "P" : "ب",
    "Q" : "ق", // ## g and 2 too
    "R" : "ر",
    "S" : "س",
    
    "T" : "ت",
    "V" : "ف",
    
    "W" : "و", //ou oo, maybe o
    "Y" : "ي", // ai, maybe a
    "Z" : "ز",
    
    /*special*/ "?" :  "؟",
                /*special*/ "," :  "،",
                            
                            //to be removed or edited later on
    "H" : "ه",
    "X" : "ة",
    "O" : "و",
    "U" : "و"
]

let breakChar = [ "-","/",":",";","(",")","$","&","@","\"",".",",","?","!","[","]","{","}","#","%","^","*","+","=","_","\\","(","|",")","~","<",">","€","£","¥","•","ـً‎","’"]

var characterSet = CharacterSet(charactersIn: "-/:;()$&@“.,?!’[]{}#%^*+=_\\|~<>€£¥• ")


// Yamli API call
func getString( word : String, withCompletion completion: @escaping ((AnyObject) -> Void)) {
    
    var word2 = word
    //Implementing URLSession
    let urlString = "https://api.yamli.com/transliterate.ashx?word=\(word2)&tool=api&account_id=&prot=https%3A&hostname=www.yamli.com&path=%2Fapi%2Fdocs%2F&build=5515"
    
    
    if word != "?"{
    guard let url = URL(string: urlString) else { return }
    
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if error != nil {
            completion(error as AnyObject)
            return
        }
            
        else if let data = data {
            do {
                let course = try JSONDecoder().decode(Root.self, from: data)
                var a = course.r
                a = a.replacingOccurrences(of: "|", with: "")
                a = a.replacingOccurrences(of: "/", with: ",")
                a = a.components(separatedBy: CharacterSet.decimalDigits).joined()
                
                completion(a as AnyObject)
            }
            catch {
                completion(error as AnyObject)
            }
        }
    }
    task.resume()
    //End implementing URLSession
    }
}


// Harakat API Call
struct Root2 : Decodable {
    private enum CodingKeys : String, CodingKey {
        case result = "result"
    }
    let result : Result
}

struct Result: Decodable {
    let translations: String
}

func getHarakatWord( word : String, withCompletion completion: @escaping ((AnyObject) -> Void)) {
    
    var word2 = word
    //Implementing URLSession
    let urlString = "https://harakat.ae/form.json?from=ara&to=ara_vocalize&text=\(word2)"
    
    guard let url = URL(string: urlString) else { return }
    
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if error != nil {
            completion(error as AnyObject)
            return
        }
            
        else if let data = data {
            do {
                let course = try JSONDecoder().decode(Root2.self, from: data)
                var a = course.result.translations
                
                completion(a as AnyObject)
            }
            catch {
                completion(error as AnyObject)
            }
        }
    }
    task.resume()
    //End implementing URLSession
}
