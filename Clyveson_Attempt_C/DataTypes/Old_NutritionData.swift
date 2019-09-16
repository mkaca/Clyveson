//
//  File.swift
//  Clyveson_Attempt_C
//
//  Created by Clyve on 8/18/19.
//  Copyright © 2019 Clyve. All rights reserved.
//

import UIKit // gives access to foundation
import os.log

// class for the meal object which we use everywhere
//   extends NSObject and NSCoding so that we can STORE the data by using NSCoding protocol (interface to runtime system)
class Old_NutritionData: NSObject, NSCoding {
    
    //MARK: Properties
    
    // note that they're var because they will change
    var name: String
    var photo: UIImage?
    var proteins: Float
    var fats: Float
    var carbs: Float
    var calories: Float
    var timestamp: Float
    //var rating: Int
    
    //MARK: Archiving Paths
    // since storage paths are static, we access outside of class with simply : Meal.ArchiveURL.path
    // finds URL within device where apps can save data
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    // appends 'meals' to url (creating new folder and storing data there)
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("NutritionData")
    
    // MARK: Types
    
    struct PropertyKey {
        static let name = "name"
        static let photo = "photo"
        static let proteins = "proteins"
        static let fats = "fats"
        static let carbs = "carbs"
        static let calories = "calories"
        static let timestamp = "timestamp"
    }
    
    //MARK: Initialization
    
    // needs to assign values to all properties
    // in our case, this will return an OPTIONAL Meal? object upon init
    init?(name: String, photo: UIImage?, proteins: Float, fats: Float, carbs: Float, calories: Float, timestamp: Float) {
        
        // Initialization should fail if there is no name or if the rating is negative.
        // The name must not be empty
        guard !name.isEmpty else {    // guard is basically an if statement. Proceeds to next line of code if statement is true
            return nil
        }
        
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.proteins = proteins
        self.fats = fats
        self.carbs = carbs
        self.calories = calories
        self.timestamp = timestamp
    }
    
    //MARK: NSCoding
    
    //prepares the class's information to be archived before closing app
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(proteins, forKey: PropertyKey.proteins)
        aCoder.encode(photo, forKey: PropertyKey.fats)
        aCoder.encode(carbs, forKey: PropertyKey.carbs)
        aCoder.encode(calories, forKey: PropertyKey.calories)
        aCoder.encode(timestamp, forKey: PropertyKey.timestamp)
    }
    
    // unarchives the data when the class is created
    // required = every sublass must call init
    // convenience = this is a secondary initializer, and that it must call a designated initializer from the same class... which it does in the last line of code in this method
    required convenience init?(coder aDecoder: NSCoder) {
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a NutritionData object.", log: OSLog.default, type: .debug)
            return nil
        }
        // Because photo is an optional property of Meal, just use conditional cast... no need for guard since photo is optional so can be nil
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        
        // These are just floats
        let proteins = aDecoder.decodeFloat(forKey: PropertyKey.proteins)
        let carbs = aDecoder.decodeFloat(forKey: PropertyKey.carbs)
        let fats = aDecoder.decodeFloat(forKey: PropertyKey.fats)
        let calories = aDecoder.decodeFloat(forKey: PropertyKey.calories)
        let timestamp = aDecoder.decodeFloat(forKey: PropertyKey.timestamp)
        
        // Must call designated initializer --> calls Meal.swift init (see above)
        self.init(name: name, photo: photo, proteins: proteins, fats: fats, carbs: carbs, calories: calories, timestamp: timestamp)
    }
    // so now we can successfully can store all nutrition data objects which should hold all the data that we need for our app
    
    
    // TODO: store nutrition data array in a new NutritionHistoryVC.swift class ... follow example of storing meals in MealTableViewController.swift class
}

