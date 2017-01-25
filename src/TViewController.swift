//
//  TUIViewController.swift
//  TSuppot
//
//  Created by Virpik on 28/12/2016.
//  Copyright © 2016 Sybis. All rights reserved.
//

import UIKit

public extension UIViewController{
    @IBInspectable var TClearBackButton:Bool{
        get {
            return true
        }
        
        set(value) {
            if (!value){
                return
            }
            
            let newBackButton = UIBarButtonItem(title: " ", style: .plain, target: self, action: nil)
            self.navigationItem.backBarButtonItem = newBackButton
        }
    }
}

public class TViewController: UIViewController {

    override public func viewDidLoad() {
        super.viewDidLoad()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
