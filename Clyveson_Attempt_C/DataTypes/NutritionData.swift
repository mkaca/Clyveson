//
//  File.swift
//  Clyveson_Attempt_C
//
//  Created by Clyve on 8/18/19.
//  Copyright © 2019 Clyve. All rights reserved.
//

import UIKit // gives access to foundation
import os.log

// class for the NutritionData object which we use everywhere

class NutritionData: NSObject {
    
    //MARK: Properties
    
    // note that they're var because they will change
    var name: String
    var photo: UIImage?
    var proteins: Float
    var fats: Float
    var carbs: Float
    var calories: Float
    var timestamp: Float
    var time: String
    //var rating: Int
    
    // MARK: Types
    
    struct PropertyKey {
         let name = "name"
         let photo = "photo"
         let proteins = "proteins"
         let fats = "fats"
         let carbs = "carbs"
         let calories = "calories"
         let timestamp = "timestamp"
         let time = "time"
    }
    
    //MARK: Initialization
    
    // needs to assign values to all properties
    // in our case, this will return an OPTIONAL Meal? object upon init
    init?(name: String, photo: UIImage?, proteins: Float, fats: Float, carbs: Float, calories: Float, timestamp: Float, time: String) {
        
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
        self.time = time
    }
    
}

