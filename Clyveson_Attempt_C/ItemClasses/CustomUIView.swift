//
//  CustomUIView.swift
//  Clyveson_Attempt_C
//
//  Created by Clyve on 8/25/19.
//  Copyright © 2019 Clyve. All rights reserved.
//

import Foundation
import UIKit

class CustomUIView: UIView{
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let colorBG = UIColor.init(displayP3Red: CGFloat(204/255), green: CGFloat(255/255), blue: CGFloat(204/255), alpha: 1.0)
        self.backgroundColor = colorBG
    }

}
