//
//  ViewController.swift
//  JHSecretLabelTest
//
//  Created by Juncheng Han on 4/10/17.
//  Copyright © 2017 JasonH. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var testLabel: JHSecretLabel!
    @IBOutlet weak var showUpBtn: UIButton!
    @IBOutlet weak var fadeOutBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        showUpBtn.isEnabled = true
        fadeOutBtn.isEnabled = false
        
        testLabel.style = .secrect
        testLabel.text = "An iPod, a phone, an internet mobile communicator...\n these are NOT three separate devices! And we are calling it iPhone! Today Apple is going to reinvent the phone.\n And here it is."
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showUpAction(_ sender: UIButton) {
        showUpBtn.isEnabled = false
        testLabel.showUpWith {
            self.fadeOutBtn.isEnabled = true
        }
    }
    
    
    @IBAction func fadeOutAction(_ sender: UIButton) {
        fadeOutBtn.isEnabled = false
        testLabel.fadeOutWith { 
            self.showUpBtn.isEnabled = true
        }
    }
}

