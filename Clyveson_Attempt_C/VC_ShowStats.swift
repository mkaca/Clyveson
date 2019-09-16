//
//  VC_ShowStats.swift
//  Clyveson_Attempt_C
//
//  Created by Clyve on 8/17/19.
//  Copyright © 2019 Clyve. All rights reserved.
//

import UIKit
import AVFoundation
import os.log
import CoreData

class VC_ShowStats: UIViewController {
    
    var foodNutrition: NutritionData?
    
    // data saving
    var foods: [NSManagedObject] = []
    
    @IBAction func doneBtn(_ sender: UIButton) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        //dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        var color = UIColor.init(displayP3Red: 0.8, green:0.5, blue: 0.1, alpha: 1.0)
        addArc(rad: 150, lineWidth: 40, color: color, perc: 0.4)
         color = UIColor.init(displayP3Red: 0.7, green:0.5, blue: 0.1, alpha: 1.0)
        addArc(rad: 110, lineWidth: 40, color: color, perc: 0.6)
         color = UIColor.init(displayP3Red: 0.6, green:0.5, blue: 0.1, alpha: 1.0)
        addArc(rad: 70, lineWidth: 40, color: color, perc: 0.9)
         color = UIColor.init(displayP3Red: 0.5, green:0.5, blue: 0.1, alpha: 1.0)
        addArc(rad: 30, lineWidth: 40, color: color, perc: 0.2)
        
        assert(foodNutrition != nil, "No food nutrition data has been sent over!!!")
        
        // saves data here
        self.save(name: foodNutrition!.name, cals: foodNutrition!.calories, proteins: foodNutrition!.proteins, fats: foodNutrition!.fats, carbs: foodNutrition!.carbs, timestamp: foodNutrition!.timestamp, time: foodNutrition!.time)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "NutritionCoreData")
        
        //3
        do {
            foods = try managedContext.fetch(fetchRequest)
            print(foods.count)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    // MARK: functional methods
    
    // e.g. 0.3 is 30%
    func calculateEndAngle(percentageAsDouble: Double) -> CGFloat {
        let endAngle:CGFloat = CGFloat(2 * .pi - (.pi * percentageAsDouble))
        return endAngle
    }
    
    func addArc(rad: CGFloat, lineWidth: CGFloat, color: UIColor, perc: Double){
        let animationCenter:CGPoint = self.view.center
        //        let animationRadius:CGFloat = 100.0
        //        let animationLineWidth:CGFloat = 16.0
        let endAngle = calculateEndAngle(percentageAsDouble: perc)
        let arcPath = UIBezierPath(arcCenter: animationCenter, radius: rad, startAngle: .pi, endAngle:endAngle, clockwise: true)
        
        let arcLayer = CAShapeLayer()
        arcLayer.path = arcPath.cgPath
        arcLayer.fillColor = UIColor.clear.cgColor
        arcLayer.strokeColor = color.cgColor
        arcLayer.lineWidth = lineWidth
        
        self.view.layer.addSublayer(arcLayer)
    }
    
    func save(name: String, cals: Float, proteins: Float, fats: Float, carbs: Float, timestamp: Float, time: String) {
        
//        guard let appDelegate =
//            UIApplication.shared.delegate as? AppDelegate else {
//                return
//        }
        
        // 1
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "NutritionCoreData",
                                       in: managedContext)!
        
        let food = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        // 3 save values to core disk storage
        food.setValue(name, forKeyPath: "name")
        food.setValue(cals, forKey: "calories")
        food.setValue(carbs, forKey: "carbs")
        food.setValue(fats, forKey: "fats")
        food.setValue(proteins, forKey: "proteins")
        //food.setValue(timestamp, forKey: "timestamp")
        food.setValue(time, forKey: "time")
        
        // 4
        do {
            try managedContext.save()
            foods.append(food)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
}
