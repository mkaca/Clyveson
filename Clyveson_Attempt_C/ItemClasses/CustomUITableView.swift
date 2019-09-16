//
//  CustomUITableView.swift
//  Clyveson_Attempt_C
//
//  Created by Clyve on 8/25/19.
//  Copyright © 2019 Clyve. All rights reserved.
//

import Foundation
import UIKit

class CustomUITableView: UITableView{
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let colorBG = UIColor.init(displayP3Red: CGFloat(102/255), green: CGFloat(255/255), blue: CGFloat(102/255), alpha: 0.9)
        self.backgroundColor = colorBG
    }
    
}
