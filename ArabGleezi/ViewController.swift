//
//  ViewController.swift
//  lisuKeyboard
//
//  Created by Amos Gwa on 12/20/16.
//  Copyright © 2016 Amos Gwa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textBox: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.textBox.text = "1234567890 1234567890 1234567890\n1234567890 1234567890 1234567890 1234567890 1234567890 1234567890"
        self.textBox.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

