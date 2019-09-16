//
//  DataTableViewCell.swift
//  Clyveson_Attempt_C
//
//  Created by Clyve on 8/22/19.
//  Copyright © 2019 Clyve. All rights reserved.
//
//
//  MealTableViewCell.swift
//  FoodTracker
//
//  Created by Michal Kaca on 7/11/19.
//  Copyright © 2019 Michal Kaca. All rights reserved.
//

import UIKit

class DataTableViewCell: UITableViewCell {
    
    // MARK: properties
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var calLabel: UILabel!
    @IBOutlet weak var protLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var carbLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.layer.borderWidth = 2.0
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor( red: 153/255, green: 153/255, blue:0/255, alpha: 1.0 ).cgColor
        
        print(makeArc(rad: 50, lineWidth: 40, color: UIColor.blue.cgColor, perc: 0.7))
        print("NIENGIEGNIEGNEIGNEI")
        self.layer.addSublayer(makeArc(rad: 20, lineWidth: 10, color: UIColor.blue.cgColor, perc: 0.4))
        self.layer.addSublayer(makeArc(rad: 30, lineWidth: 10, color: UIColor.yellow.cgColor, perc: 0.9))
        self.layer.addSublayer(makeArc(rad: 40, lineWidth: 10, color: UIColor.green.cgColor, perc: 0.6))
        self.layer.addSublayer(makeArc(rad: 50, lineWidth: 10, color: UIColor.red.cgColor, perc: 0.8))
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    // create arc
    func makeArc(rad: CGFloat, lineWidth: CGFloat, color: CGColor, perc: Double) -> CAShapeLayer{
        let animationCenter:CGPoint = CGPoint(x: 80, y: 80)
        //        let animationRadius:CGFloat = 100.0
        //        let animationLineWidth:CGFloat = 16.0
        let endAngle = calculateEndAngle(percentageAsDouble: perc)
        let arcPath = UIBezierPath(arcCenter: animationCenter, radius: rad, startAngle: 0, endAngle:endAngle*2, clockwise: false)
        print(arcPath)

        let arcLayer = CAShapeLayer()
        arcLayer.path = arcPath.cgPath
        arcLayer.fillColor = UIColor.clear.cgColor
        arcLayer.strokeColor = color
        arcLayer.lineWidth = lineWidth

        return arcLayer
        //        self.view.layer.addSublayer(arcLayer)
    }


    // helper function
    func calculateEndAngle(percentageAsDouble: Double) -> CGFloat {
        let endAngle:CGFloat = CGFloat(2 * .pi - (.pi * percentageAsDouble))
        return endAngle
    }
    


    
}
