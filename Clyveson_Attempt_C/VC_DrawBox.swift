//
//  DrawBoxVC.swift
//  Clyveson_Attempt_C
//
//  Created by Clyve on 8/17/19.
//  Copyright © 2019 Clyve. All rights reserved.
//

import UIKit
import AVFoundation
import os.log
import MobileCoreServices

class VC_DrawBox: UIViewController {
    
    // MARK: properties
    
    var snappedPhotoView: AVCapturePhoto?
    var depthDataOG: AVDepthData?
    var lastPoint = CGPoint.zero // last point init
    var currentPoint = CGPoint.zero // current point init
    var swiped = false
    var rect = CGRect(x: 0, y: 0, width: 0, height: 0) // init empty rectange
    let navBarHeight: CGFloat = 88 // navigation bar height
    var imageResized: Bool = false // flag for scaling --> workaround with failed first rect grab
    var red: CGFloat = 200
    var green: CGFloat = 25
    var blue: CGFloat = 20
    var brushWidth: CGFloat = 4.0 // brush width in pixels
    var firstY: CGFloat = 0 // init arbitrary
    var label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0)) // init label
    var visibleImageMinLimit = 0 // init placeholders
    var visibleImageMaxLimit = 0 //init placeholders
    var foodNutrition: NutritionData?
    var textField = DropDown()
    
    // flag for transitioning between VCs
    //var addingMeal = true // default value
    
    // displays photo captured
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var tempDrawingImageView: UIImageView!
    
    
    // MARK: Actions
    
    // Will go back to old VC to retake picture
    @IBAction func reTakeBtn(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
        sender.style = UIBarButtonItem.Style.done
    }
    
    // resets tempImageView, removes label, to allow user to draw again
    @IBAction func drawAgain(_ sender: UIButton) {
        tempDrawingImageView.image = nil
        self.label.removeFromSuperview()
    }
    
    // adds meal and navigates to 3rd VC
    @IBAction func addMealBtn(_ sender: UIButton) {
        // save data and then load stats
        //saveData()
        performSegue(withIdentifier: "showStatsSegue", sender: self)
    }
    
    // drops down items from food list if ML was wrong... shows most recent first
    // TODO: add functionality for values
    //@IBOutlet weak var dropDownMenu: DropDown!
    
    
    // MARK: VC methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets dropdown
        // The list of array to display. Can be changed dynamically
//        dropDownMenu.optionArray = ["Potatoes", "Cabbage", "Deez Nuts","kitties"]
//        //Its Id Values and its optional
//        dropDownMenu.optionIds = [1,23,54,22]
//        // The the Closure returns Selected Index and String
//        dropDownMenu.didSelect{(selectedText , index ,id) in
//            self.label.text = "Chosen: \(selectedText) \n index: \(index)"}
        
        // convert to UIImage and set imageView
        guard let cgImage = snappedPhotoView?.cgImageRepresentation()?.takeUnretainedValue() else { return }
        
        let orientation = snappedPhotoView?.metadata[kCGImagePropertyOrientation as String] as? NSNumber
        let uiOrientation = UIImage.Orientation(rawValue: orientation?.intValue ?? UIImage.Orientation.left.rawValue)
        print("ORIENTATION \(uiOrientation?.rawValue)")
        
        //let image = UIImage(cgImage: cgImage, scale: 1, orientation: uiOrientation!)
        let image = UIImage(cgImage: cgImage, scale: 1, orientation: UIImage.Orientation(rawValue: UIImage.Orientation.right.rawValue)!)
        photoImageView.image = image
        print (image)
        print(image.size)
        
        let imgScale = image.size.width / image.size.height
        let actualImageHeight = self.view.bounds.width / imgScale
        visibleImageMinLimit = Int(self.view.bounds.height/2 - actualImageHeight / 2)
        visibleImageMaxLimit = Int(self.view.bounds.height/2 + actualImageHeight / 2)

        photoImageView.contentMode = .scaleAspectFit
        
        
        // set z-priorities
        photoImageView.layer.zPosition = 5 // closer to back
        tempDrawingImageView.layer.zPosition = 10
        
        assert (snappedPhotoView != nil, "Can't analyze an empty photo")
    }
    
    // get our selected text and use its data as our calories, proteins, etc when saving :)
    override func viewWillLayoutSubviews() {
        guard let cleanText = textField.text else{
            fatalError("textField unwrapped a nil value")
        }
        print("Textifledtext: \(cleanText)")
        
    }
    
    // MARK: drawing methods
    
    // ALL touch notifying methods come from parent UIResponder
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        firstY = touches.first?.location(in: self.view).y ?? 0
        // print("LocationOfTouch: \(touches.first?.location(in: self.view).y)")
        
        if Int(firstY) > visibleImageMinLimit && Int(firstY) < visibleImageMaxLimit{
            guard let touch = touches.first else {
                return
            }
            swiped = false
            lastPoint = touch.location(in: view)
            currentPoint = touch.location(in: view)
            
            // adaptation for newDraw
            //tempDrawingImageView.image = nil
        }
    }
    
    // is called when touch has moved
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if Int(firstY) > visibleImageMinLimit && Int(firstY) < visibleImageMaxLimit{
            guard let touch = touches.first else {
                return
            }
            
            // checks if moving
            swiped = true
            if Int(touch.location(in: view).y) > visibleImageMinLimit && Int(touch.location(in: view).y) < visibleImageMaxLimit{
                currentPoint = touch.location(in: view)
            }
            //implement drawsquare
            drawSquare(from: lastPoint, to: currentPoint)
        }
    }
    
    // is called when touch is no longer happening
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
         if Int(firstY) > visibleImageMinLimit && Int(firstY) < visibleImageMaxLimit{
            if !swiped {
                // draw a single point in case user simply taps the screen to draw a dot
                //drawLine(from: lastPoint, to: lastPoint)
            }
            else{
                //drawLine(from: lastPoint, to: currentPoint)
            }
            
            
                // crop imageView of photo taken and can save to photos library for visual verification
                guard let img = photoImageView.image else { return }
                print("cropping now")
                let croppedImage = cropImage(img, toRect: rect)!
                // save cropped image to photos to analyze
                //UIImageWriteToSavedPhotosAlbum(croppedImage!, self, nil, nil)
    
            
/*
            // scaling done here with contexts
            let imageRatio = photoImageView.image!.size.width/photoImageView.image!.size.height
            let newWidth = imageRatio * (view.bounds.height - navBarHeight)
            //print(newWidth)
            let newRectBoundsInDev: CGRect = CGRect(x: -(newWidth - view.bounds.width)/2, y: 0, width: newWidth, height: view.bounds.height - navBarHeight)
            UIGraphicsBeginImageContextWithOptions(photoImageView.frame.size, false, 1.0)
            let offSetBounds: CGRect = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - navBarHeight)
            //print (offSetBounds)
            
            // set boxes drawn on the tempDrawingImageView (their context) to photoImageView context
            photoImageView.image?.draw(in: newRectBoundsInDev, blendMode: .normal, alpha: 1.0)
            tempDrawingImageView?.image?.draw(in: offSetBounds                                                         , blendMode: .normal, alpha: 0.8)
            photoImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            //reset tempImageView to nil to get ready for next drawing segment
            tempDrawingImageView.image = nil
 */
            
            // set stroke colors--> even though they are not setting
            red = CGFloat.random(in: 0 ... 255)
            green = CGFloat.random(in: 0 ... 255)
            blue = CGFloat.random(in: 0 ... 255)
            print("blue \(blue)")
            
                ////// begin analyzing the image here with ML using the cropped Img
//                analyzeWithML(image: croppedImage)
               //
            /////////// /////////// /////////// /////////// TO DO
            //
            //       ADD COMPLETION CALLBACK FOR ASYNC CLEANLINESS AND SO THAT IT DOESN'T BLOCK THE THREADS THUS TAKING 15 SECONDS!!!!!!
            /////////////// /////////// /////////// /////////// ///////////
                let (name, protein, fats, carbs, calories) = fetchFromServer(image: croppedImage)
//                sleep(5)   /// TEMP SLEEP FOR MVP TO FETCH DATA
                //////// end analyzing image with ML here
                // create label
//                createLabel(textName: foodNutrition?.name ?? "Empty Name")
            
                // get depthInfo
                //getDepth(photo: self.snappedPhotoView!)
                //getDepthOfPoint(photo: self.snappedPhotoView!, point: currentPoint)
            
        }
        
        print("FRAME: \(self.photoImageView.bounds)")
        print("SIZE: \(self.photoImageView.image?.size)")
        print("SCALE: \(self.photoImageView.image?.scale)")
        print("FRAMEtemp: \(self.tempDrawingImageView.bounds)")
        print("SIZEtemp: \(self.tempDrawingImageView.image?.size)")
        print("view bounds: \(self.view.bounds)")
        print("view frame: \(self.view.frame)")
        
        print( "function ended")
        //devMonstar edit --> show cropped image
        //tempDrawingImageView.image = croppedImage
    }
    
    
    // MARK: Functional Methods
    
    func drawSquare(from fromPoint: CGPoint, to toPoint: CGPoint) {
        
        // 1 Sets context
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            print ("well, fuck")
            return
        }
        
        //scaling done here with drawing contexts
        tempDrawingImageView.image = nil  // set image to overlap for drawing
        let imageRatio = photoImageView.image!.size.width/photoImageView.image!.size.height
        let newWidth = imageRatio * (view.bounds.height - navBarHeight)
        let newRectBoundsInDev: CGRect = CGRect(x: -(newWidth - view.bounds.width)/2, y: 0, width: newWidth, height: view.bounds.height - navBarHeight)
        //print(newRectBoundsInDev)
        //tempDrawingImageView.image?.draw(in: newRectBoundsInDev)
        tempDrawingImageView.image?.draw(in: self.photoImageView.bounds)
        
        // 2 This will produce straight lines, but the touch events fire so quickly that the lines are short enough and the result will look like a nice smooth curve
        context.move(to: fromPoint)
        //context.addLine(to: toPoint)
        // draw rectangle based on line
        let originX = min(fromPoint.x, toPoint.x)
        let originY = min(fromPoint.y, toPoint.y)
        let width = abs(fromPoint.x - toPoint.x)
        let height = abs(fromPoint.y - toPoint.y)
        rect = CGRect(x: originX, y: originY - 0, width: width, height: height)
        context.addRect(rect)
        
        // 3 sets params, see CGContext for more
        context.setLineCap(.round)
        context.setBlendMode(.normal)
        context.setLineWidth(brushWidth)
        
        // sets random stroke color for nice design
        let color = UIColor.init(displayP3Red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1.0)
        context.setStrokeColor(color.cgColor)
        
        // 4 actually draw path here
        context.strokePath()
        
        // 5 get image from image context and set the tempImageView to it
        tempDrawingImageView.image = UIGraphicsGetImageFromCurrentImageContext()!
        tempDrawingImageView.alpha = 0.8
        UIGraphicsEndImageContext()
    }
    
    
    
    // creates label using most recent currentPoint and lastPoint variables
    func createLabel(textName: String){
        let centerX = (currentPoint.x + lastPoint.x)/2
        let centerY = (currentPoint.y + lastPoint.y)/2
//          let widthImg = abs(currentPoint.x - lastPoint.x)
//          let heightImg = abs(currentPoint.y - lastPoint.y)
        
        // Create dropdown here
        self.textField.removeFromSuperview()
        textField.frame.size = CGSize(width: 200, height: 25)
        textField.text = textName
        textField.textAlignment = NSTextAlignment.center
        textField.backgroundColor = UIColor.white
        textField.optionArray = ["Potatoes", "Cabbage", "Deez Nuts","kitties"]
        //Its Id Values and its optional
        textField.optionIds = [1,23,54,22]
        // The the Closure returns Selected Index and String
        textField.didSelect{(selectedText , index ,id) in
            self.label.text = "Chosen: \(selectedText) \n index: \(index)"}
        textField.center = CGPoint(x: centerX, y: centerY)
        self.view.addSubview(textField)
        self.photoImageView.layer.zPosition = -5;
        textField.layer.zPosition = 15;
    
        print("done creating label")
    }
    
    func analyzeWithML(image: UIImage){
        // ML magic here --> outputs name, proteins, fats, carbs
        // fetch data from server
        let (name, protein, fats, carbs, calories) = fetchFromServer(image: image)
        
//        let placeHolderName = "Potatoes"
//        let placeHolderProteins = Float(24.2)
//        let placeHolderFats = Float(12.2)
//        let placeHolderCarbs = Float(59.8)
//        let placeHolderCalories = Float(59.8)
        let timestamp = Date().currentTimeMillis()
        let currentTime = generateCurrentTimeStamp()
        print("timestamp is \(timestamp)")
        foodNutrition = NutritionData(name: name, photo: image, proteins: protein, fats: fats, carbs: carbs, calories: calories, timestamp: timestamp, time: currentTime)
    }
    
    // crops image
    func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect) -> UIImage?
    {
        //    let imageViewScale = max(inputImage.size.width / viewWidth,
        //                             inputImage.size.height / viewHeight)
        
        // Scale cropRect to handle images larger than shown-on-screen size
        var imageViewScaleX: CGFloat = 1
        var imageViewScaleY: CGFloat = 1
        let scale = self.photoImageView.image!.scale
        //print("scale: \(scale)")
        
        // DOES NOT WORK
        if  !imageResized{
            //inputImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
            imageViewScaleX = inputImage.size.width / view.bounds.width
            imageViewScaleY = inputImage.size.height / view.bounds.height
        }
        //         print("x: \(cropRect.origin.x * imageViewScaleX), y: \(cropRect.origin.y * imageViewScaleY), width: \(cropRect.size.width * imageViewScaleX), height: \(cropRect.size.height * imageViewScaleY),")
        let cropZone = CGRect(x:cropRect.origin.x * imageViewScaleX,
                              y:(cropRect.origin.y - 88/2) * imageViewScaleY,
                              width:cropRect.size.width * imageViewScaleX,
                              height:cropRect.size.height * imageViewScaleY)
        
        // Perform cropping in Core Graphics
        guard let croppedCGImage: CGImage = inputImage.cgImage?.cropping(to:cropZone)
            else {
                return nil
        }
        
        let croppedImage = UIImage(cgImage: croppedCGImage, scale: scale, orientation: .up)
        return croppedImage
    }

    
    // MARK: - Navigation
    
    // Prepares for navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "showStatsSegue"  {
            os_log("Viewing Image", log: OSLog.default, type: .debug)
            
            // sets destination
            let nav = segue.destination as! UINavigationController
            
            guard let statsVC = nav.topViewController as? VC_ShowStats else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            //sets results for transfering to next VC
            statsVC.foodNutrition = foodNutrition
            
            
        }
    }
    
    func generateCurrentTimeStamp () -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd_hh_mm_ss"
        return (formatter.string(from: Date()) as NSString) as String
    }
    

// MARK: SERVER FETCHING

    func fetchFromServer(image: UIImage) -> (String, Float, Float, Float, Float) {
        var request: URLRequest
        // placeholders
        var name = "filler"
        var proteins: Float = 69.9
        var carbs: Float = 69.9
        var calories: Float = 69.9
        var fats: Float = 69.9
        
        do {
            request = try createRequest(userid:"test", password: "test", email: "test", crImg: image)
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                // handle error here
                print(error ?? "Unknown error")
                return
            }
            
            let httpResponse = response as? HTTPURLResponse
            print("status code is: \(httpResponse?.statusCode)")
            
            let strData = String(decoding: data, as: UTF8.self)
            print("strData is :\(strData)")
            
            do{
                let jsonDataTest = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String : Any]
                
                print("jsonData is :\(jsonDataTest)")
                //        let results = jsonDataTest!["result"]
                //        print(results)
                
                let resultArr = jsonDataTest.flatMap { $0["result"] as! [String] }
                name = resultArr![0]
                print(name)
                
                let caloriesArr = jsonDataTest.flatMap {$0["calories"] as! [NSNumber]}
                calories = caloriesArr![0].floatValue
                print(calories)
                let fatArr = jsonDataTest.flatMap {$0["fat_weight"] as! [NSNumber] }
                fats = fatArr![0].floatValue
                let carbArr = jsonDataTest.flatMap {$0["carbohydrate_weight"] as! [NSNumber] }
                carbs = carbArr![0].floatValue
                let protArr = jsonDataTest.flatMap {$0["protein_weights"] as! [NSNumber] }
                proteins = protArr![0].floatValue
                
                // Code below is for generating data from Server
                let timestamp = Date().currentTimeMillis()
                let currentTime = self.generateCurrentTimeStamp()
                print("timestamp is \(timestamp)")
                self.foodNutrition = NutritionData(name: name, photo: image, proteins: proteins, fats: fats, carbs: carbs, calories: calories, timestamp: timestamp, time: currentTime)
                self.createLabel(textName: self.foodNutrition?.name ?? "Empty Name")
                
            }
            catch{
                print( "Failed to convert data from server to JSON!!! :(")
            }
            
            // parse `data` here, then parse it
            
            // note, if you want to update the UI, make sure to dispatch that to the main queue, e.g.:
            //
            // DispatchQueue.main.async {
            //     // update your UI and model objects here
            // }
        }
        task.resume()
        } catch {
            print(error)
        }
        return (name, proteins, fats, carbs, calories)
    }


    func createRequest(userid: String, password: String, email: String, crImg: UIImage) throws -> URLRequest {
        let parameters = [
            "user_id"  : userid,
            "email"    : email,
            "password" : password]  // build your dictionary however appropriate
        
        let boundary = generateBoundaryString()
        
        let url = URL(string: "https://www.floydlabs.com/serve/mjjere/projects/fittrex/predict")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try createBody(with: parameters, filePathKey: "file", image: crImg, boundary: boundary)
        
        return request
    }

    /// Create body of the `multipart/form-data` request
    ///
    /// - parameter parameters:   The optional dictionary containing keys and values to be passed to web service
    /// - parameter filePathKey:  The optional field name to be used when uploading files. If you supply paths, you must supply filePathKey, too.
    /// - parameter paths:        The optional array of file paths of the files to be uploaded
    /// - parameter boundary:     The `multipart/form-data` boundary
    ///
    /// - returns:                The `Data` of the body of the request

    private func createBody(with parameters: [String: String]?, filePathKey: String, image: UIImage, boundary: String) throws -> Data {
        var body = Data()
        
            let filename = "Irrelevant"
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(filename)\"\r\n")
            let hardCore: String = "image/png"
            body.append("Content-Type: \(hardCore)\r\n\r\n")
            var imageData = image.pngData() // convert to png data from UIImage here
            body.append(imageData!)
            body.append("\r\n")
        
        body.append("--\(boundary)--\r\n")
        return body
    }

    /// Create boundary string for multipart/form-data request
    ///
    /// - returns:            The boundary string that consists of "Boundary-" followed by a UUID string.

    private func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
}

// MARK: extensions

extension Date {
    func currentTimeMillis() -> Float {
        return Float(self.timeIntervalSince1970 * 1000)
    }
}


extension Data {
    
    /// Append string to Data
    ///
    /// Rather than littering my code with calls to `data(using: .utf8)` to convert `String` values to `Data`, this wraps it in a nice convenient little extension to Data. This defaults to converting using UTF-8.
    ///
    /// - parameter string:       The string to be added to the `Data`.
    
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}
