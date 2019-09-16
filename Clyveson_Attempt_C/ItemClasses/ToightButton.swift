//
//  ToightButton.swift
//  Clyveson_Attempt_C
//
//  Created by Clyve on 8/24/19.
//  Copyright © 2019 Clyve. All rights reserved.
//

import Foundation
import UIKit

class ToightButton: UIButton{
    
    
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.isEnabled = false
        let colorBG = UIColor.init(displayP3Red: CGFloat(200/255), green: CGFloat(200/255), blue: CGFloat(255/255), alpha: 0.3)
        let colorTextSelected = UIColor.init(displayP3Red: CGFloat(20/255), green: CGFloat(0/255), blue: CGFloat(20/255), alpha: 1.0)
        let colorTextDefault = UIColor.init(displayP3Red: CGFloat(0/255), green: CGFloat(20/255), blue: CGFloat(20/255), alpha: 1.0)
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 15
        // normal bg and text
        self.setTitleColor(colorTextDefault, for: UIControl.State.normal)
        self.backgroundColor = colorBG
        
        // highlighted text
        self.setTitleColor(colorTextSelected, for: UIControl.State.highlighted)
        self.setTitleShadowColor(colorTextSelected, for: UIControl.State.highlighted)
        
        self.isEnabled = true
        
        
    }
    
}
