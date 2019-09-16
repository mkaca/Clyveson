//
//  T_VC_History.swift
//  Clyveson_Attempt_C
//
//  Created by Clyve on 8/20/19.
//  Copyright © 2019 Clyve. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class T_VC_History : UITableViewController{
    
    //  this is taking static struct, and could be nil at any time
    //var nutrData: [NutritionData]? = []
    
    // NSCore
    var foods: [NSManagedObject] = []
    var nutrDatas: [NSManagedObject] = []
    
    
    @IBOutlet var oneTableBoi: UITableView!
    
    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "HISTORY SUMMARY" // sets nav bar title
        //Note: register(_:forCellReuseIdentifier:) guarantees your table view will return a cell of the correct type when the Cell reuseIdentifier is provided to the dequeue method.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "NutritionCoreData")
        
        //3
        do {
            print(foods.count)
            foods = try managedContext.fetch(fetchRequest)
            print(foods.count)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        

    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foods.count
        //return nutrData?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0//Choose your custom row height
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            let food = foods[indexPath.row]
            // Since we are using a custom cell class
            let cellIdentifier = "DataTableViewCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DataTableViewCell  else {
                fatalError("The dequeued cell is not an instance of DataTableViewCell.")
            }
           
            
            //cell.textLabel?.text = nutrData?[indexPath.row].name ?? "no name found"
            cell.nameLabel?.text =  food.value(forKeyPath: "name") as? String
            let caltext = food.value(forKeyPath: "calories") ?? 0
            cell.calLabel?.text = "\(caltext)"
            let protText = food.value(forKeyPath: "proteins") ?? 0
            cell.protLabel?.text = "\(protText)"
            let fatText = food.value(forKeyPath: "fats") ?? 0
            cell.fatLabel?.text = "\(fatText)"
            let carbText = food.value(forKeyPath: "carbs") ?? 0
            cell.carbLabel?.text = "\(carbText)"
//            let timeText = food.value(forKeyPath: "timestamp") ?? 0
            cell.timeLabel?.text = food.value(forKeyPath: "time") as? String
            
            // Add the rectangle to your cell
            //cell.addSubview(makeRectangle(textBoi: cell.nameLabel!.text!))
            
            return cell
    }
    
    
    
    // create arc
    func makeArc(rad: CGFloat, lineWidth: CGFloat, color: CGColor, perc: Double) -> CAShapeLayer{
        let animationCenter:CGPoint = self.view.center
        //        let animationRadius:CGFloat = 100.0
        //        let animationLineWidth:CGFloat = 16.0
        let endAngle = calculateEndAngle(percentageAsDouble: perc)
        let arcPath = UIBezierPath(arcCenter: animationCenter, radius: rad, startAngle: .pi, endAngle:endAngle, clockwise: true)
        
        let arcLayer = CAShapeLayer()
        arcLayer.path = arcPath.cgPath
        arcLayer.fillColor = UIColor.clear.cgColor
        arcLayer.strokeColor = color
        arcLayer.lineWidth = lineWidth
    
        return arcLayer
//        self.view.layer.addSublayer(arcLayer)
    }
    
    // test function
    func makeRectangle(textBoi: String) -> UIView{
        // Add a rectangle view
        let label = UILabel()
        label.text = textBoi
        label.sizeToFit()
        let rectangle = UIView(frame: CGRect(x: 0, y: 0, width: label.frame.size.width, height: 40))
        
        // Add gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = rectangle.bounds
        
        let color1 = UIColor.yellow.cgColor
        let color2 = UIColor(red: 1.0, green: 0, blue: 0, alpha: 1.0).cgColor
        let color3 = UIColor.clear.cgColor
        let color4 = UIColor(white: 0.0, alpha: 0.7).cgColor
        
        gradientLayer.colors = [color1, color2, color3, color4]
        gradientLayer.locations = [0.0, 0.25, 0.75, 1.0]
        rectangle.layer.addSublayer(gradientLayer)
        
        rectangle.addSubview(label)
        
        // Add corner radius
        gradientLayer.cornerRadius = 10
        //rectangle.layer.addSublayer(<#T##layer: CALayer##CALayer#>)
        
        return rectangle
    }
    
    // helper function
    func calculateEndAngle(percentageAsDouble: Double) -> CGFloat {
        let endAngle:CGFloat = CGFloat(2 * .pi - (.pi * percentageAsDouble))
        return endAngle
    }

}
