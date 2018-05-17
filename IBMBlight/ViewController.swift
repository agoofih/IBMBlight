//
//  ViewController.swift
//  IBMBlight
//
//  Created by Daniel T. Barwén on 2018-03-22.
//  Copyright © 2018 Daniel T. Barwén. All rights reserved.
//

import UIKit
import CoreLocation
import Photos
import MapKit
import MessageUI
import MobileCoreServices
import Alamofire

struct TopResponse : Decodable {
    let files : [Response]
}
struct Response : Decodable {
    let blightscore : Double
    let coords : [Double]
    let url : String
}
struct getID : Decodable {
    let classifier_id : String
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, MFMailComposeViewControllerDelegate, MKMapViewDelegate {
    
    
    
    //------------------------------ ------------------------------ -------------------------------
    
    //------------------------------ Outlets and standard variables -------------------------------
    
    //------------------------------ ------------------------------ -------------------------------
    
    
    
    //Loadingscreen
    @IBOutlet weak var preScreen: UIView!
    
    //Main scrollView
    @IBOutlet weak var mainScrollview: UIScrollView!

    //Top mapView wrapper
    @IBOutlet weak var mainMapView: MKMapView!
    
    //CRV = cameraResultView
    @IBOutlet weak var cameraResultView: UIView!
    @IBOutlet weak var CRVheader: UILabel! //
    @IBOutlet weak var CRVsuggestedInfectionHeader: UILabel! //
    @IBOutlet weak var CRVsuggestedInfectionTypeValue: UILabel! //
    @IBOutlet weak var CRVprababilityHeader: UILabel! //
    @IBOutlet weak var CRVprobabilityDegreeValue: UILabel! //
    @IBOutlet weak var CRVstageHeader: UILabel! //
    @IBOutlet weak var CRVstageValue: UILabel! //
    @IBOutlet weak var CRVblightScore: UILabel!
    @IBOutlet weak var CRVsendResult: UIButton! //
    @IBOutlet weak var CRVcloseBtn: UIButton!
    @IBOutlet weak var imageResultView: UIImageView!
    @IBOutlet weak var imageResultViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageResultViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var CRVSendView: UIView!
    @IBOutlet weak var newsViewWrapper: UIView!
    
    @IBOutlet weak var graphViewWrapper: UIView!
    @IBOutlet weak var cameraResultViewWrapper: UIView!
    @IBOutlet weak var CRVanalyzeButton: UIButton!
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var topWeatherContainerView: UIView!
    
    //Alert view wrapper
    @IBOutlet weak var alertView: UIView!
    
    //Latest news wrapper
    @IBOutlet weak var newsView: UIView!
    
    //Height of the alertview
    @IBOutlet weak var alertViewHeightConstraint: NSLayoutConstraint!
    
    //Hegith of the newsView
    @IBOutlet weak var newsViewHeightConstraint: NSLayoutConstraint!
    
    
    var locationManager : CLLocationManager!
    
    //Base setup, GPS to IBM Malmö
    var location_lat = 55.611868
    var location_lng = 12.977738
    
    //Mailadress user puts in befor sending the report
    var recipientValueMail : String = ""
    
    var todaysDate : String = ""

    var alertsBool = false
    var newsBool = false
    
    // variales used for sending Image for analyzation.
    var sendImage : UIImage = UIImage()
    var sendClassifierId : String = ""
    var sendTileImages : String = "true"
    var sendLat : String = ""
    var sendLng : String = ""
    
    // turns the picked UIImage to NSData so it can be stored in userDefault and sent for analyzation.
    var imageData : NSData? = nil
    
    var base64StringImage : String = "awdad"
    
    var filepathcomplete : String = ""
    
    var urlSend : String = ""
    
    var sendResultAlert = UIAlertController()
    var dataUsageAlert = UIAlertController()
    
    // changes depending on the alert
    var dataUsageAlertTitle = ""
    var dataUsageAlertText = ""
    
    // calculator for % in blightscoore
    var scoreCalc : Double = 0.0
    
    // coords we get from response after picture is analyzed
    var reciveLat : Double = 0.0
    var reciveLng : Double = 0.0
    
    
    //------------------------------ ------------------------------ -------------------------------
    
    //------------------------------ Basics -------------------------------

    //------------------------------ ------------------------------ -------------------------------
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageResultViewHeightConstraint.constant = 0
        imageResultViewTopConstraint.constant = 0
        cameraResultView.isHidden = true
        locationManager = CLLocationManager()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        mainMapView.delegate = self
        getCurrentDateTime()
    }
    
    //Changes the top statusbar to white
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            UIView.animate(withDuration: 0.3, animations: {
                self.preScreen.alpha = 0
            }, completion: nil)
        })
        
        //Preload last choosen image and show it
        if UserDefaults.standard.value(forKey: "savedImage") == nil {
        }else{
            cameraResultView.dropShadowRemove()
            cameraResultView.isHidden = false
            imageResultViewHeightConstraint.constant = 350
            imageResultViewTopConstraint.constant = 25
            
            let savedImage = UserDefaults.standard.object(forKey: "savedImage") as! NSData
//            imageResultView.image = UIImage(data: savedImage as Data)
            let currentUIImage = UIImage(data: savedImage as Data)
            self.imageResultView.image = rotateImage(image: currentUIImage!)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.cameraResultView.BadgeView()
            }
        }
        
        topWeatherContainerView.dropShadow()
        mapContainerView.dropShadow()
        
        alertView.BadgeView()
        CRVanalyzeButton.BadgeView()
        graphViewWrapper.BadgeView()
        
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
        }else{
            let alert = UIAlertController(title: "No internet connection", message: "Please check your connection and then restart the application", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
        getClassifierID()
    }
    
    func rotateImage(image:UIImage) -> UIImage
    {
        var rotatedImage = UIImage()
        switch image.imageOrientation
        {
        case .right:
            rotatedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .down)
            
        case .down:
            rotatedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .left)
            
        case .left:
            rotatedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .up)
            
        default:
            rotatedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .right)
        }
        
        return rotatedImage
    }
    
    
    //------------------------------ ------------------------------ -------------------------------
    
    //------------------------------ Map -------------------------------
    
    //------------------------------ ------------------------------ -------------------------------
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        location_lat = userLocation.coordinate.latitude
        location_lng = userLocation.coordinate.longitude
        sendLat = "\(userLocation.coordinate.latitude)"
        sendLng = "\(userLocation.coordinate.longitude)"
    }
    
    
    
    //------------------------------ ------------------------------ -------------------------------
    
    //------------------------------ Weather -----------------------------
    
    //------------------------------ ------------------------------ -------------------------------
    
    
    // Seperate VC - TopWeatherDataVC & WeatherServer
    
    
    //------------------------------ ------------------------------ -------------------------------

    //------------------------------ Camera -------------------------------
    
    //------------------------------ ------------------------------ -------------------------------
    
    

    @IBAction func getFromCamera(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func getFromGallery(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        cameraResultView.isHidden = false
        
        cameraResultView.dropShadowRemove()
        imageResultViewHeightConstraint.constant = 350
        imageResultViewTopConstraint.constant = 25
        let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        sendImage = pickedImage
        sendTileImages = "true"
        
        imageData = UIImagePNGRepresentation(pickedImage)! as NSData
        base64StringImage = imageData?.base64EncodedString() ?? "" // Your String Image
        
        //Save image userDefaults
        UserDefaults.standard.set(imageData, forKey: "savedImage")
        
        //Decode image and display
        let activeImage = UserDefaults.standard.object(forKey: "savedImage") as! NSData
//        imageResultView.image = UIImage(data: activeImage as Data)
        let currentUIImage = UIImage(data: activeImage as Data)
        self.imageResultView.image = rotateImage(image: currentUIImage!)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.cameraResultView.dropShadow()
        }
        self.CRVSendView.isHidden = false
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //------------------------------ ------------------------------ -------------------------------
    
    //------------------------------ Analyze View -------------------------------
    
    //------------------------------ ------------------------------ -------------------------------
    
    
    
    @IBAction func analyzeClick(_ sender: UIButton) {
        print("SEND")
        if imageResultView.image != nil {
            let img = imageResultView.image
            let data = UIImageJPEGRepresentation(img!, 1.0)
            
            print("**** - Classifierid: \(sendClassifierId), lat: \(location_lat), lng: \(location_lng)")
            let para = ["tile_images" : "true", "classifier_id" : sendClassifierId, "lat" : location_lat, "lng" : location_lng] as [String : Any]
            
            sendDataFunc(endUrl: urlSend, imageData: data, parameters: para)
        } else {
            self.dataUsageAlertTitle = "Could not send the image to the sky"
            self.dataUsageAlertText = "There was a problem with sending the image, check your internet connection and restar the application. If the problem persists, contact the IT wizards"
            self.dataUsageError()
        }
    }
    

    
    //------------------------------ ------------------------------ -------------------------------
    
    //------------------------------ Alamofire Send and recive data -------------------------------
    
    //------------------------------ ------------------------------ -------------------------------
    
    
    
    
    func sendDataFunc(endUrl: String, imageData: Data?, parameters: [String : Any], onError: ((Error?) -> Void)? = nil){
        let sv = UIViewController.displaySpinner(onView: self.view)
        urlSend = "https://blighttoaster.eu-gb.mybluemix.net/api/analyze_images"
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = 300
            
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            if let data = imageData{
                multipartFormData.append(data, withName: "files[]", fileName: "image.jpeg", mimeType: "image/jpeg")
                
            }
            
        }, usingThreshold: UInt64.init(), to: urlSend, method: .post, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("Succesfully uploaded")
                    if let err = response.error{
                        onError?(err)
                        UIViewController.removeSpinner(spinner: sv)
                        self.dataUsageAlertTitle = "No response from the server"
                        self.dataUsageAlertText = "There was no response from the server, please check your internet connection and try again, if the problem persists, contact the IT wizards"
                        self.dataUsageError()
                        return
                    }
                    var highResultScore = 0.0
                    var highResultCoords = [Double]()
                    var highResultUrl = ""

                    do {
                        let topResponse = try JSONDecoder().decode(TopResponse.self, from: response.data!)
                   
                        for response in topResponse.files {
                            if response.blightscore > highResultScore {
                                highResultScore = response.blightscore
                                highResultCoords = response.coords
                                highResultUrl = "https://blighttoaster.eu-gb.mybluemix.net\(response.url)"
                                self.scoreCalc = highResultScore * 100

                                
                                self.imageResultView.downloadedFrom(link: highResultUrl)

                                if self.scoreCalc <= 30.0 {
                                    self.CRVblightScore.textColor = UIColor(named: "darkGreen")
                                } else if self.scoreCalc > 30.0 && self.scoreCalc < 60.0 {
                                    self.CRVblightScore.textColor = UIColor(named: "darkYellow")
                                } else {
                                    self.CRVblightScore.textColor = UIColor(named: "darkRed")
                                }
                                let x = self.scoreCalc
                                let y = Double(round(100*x)/100)
                                self.CRVblightScore.text = "\(y) %"

                            }
                        }
                        
                        print("---- Highest blightscore is: \(highResultScore) and the coords is: \(highResultCoords) and the imageURL is: \(highResultUrl) ----")
                        self.CRVSendView.isHidden = true
                        UIViewController.removeSpinner(spinner: sv)
                        
                        
                    } catch {
                        print("response.debugDescription ERROR: ", response.debugDescription)
                        UIViewController.removeSpinner(spinner: sv)
                        
                        self.dataUsageAlertTitle = "Problem with data"
                        self.dataUsageAlertText = "There was a problem with the retrival of data, restar the application and try again, if the problem persists, contact the IT wizards"
                        self.dataUsageError()
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                onError?(error)
                UIViewController.removeSpinner(spinner: sv)
                self.dataUsageAlertTitle = "Problem with upload"
                self.dataUsageAlertText = "There was no response from the server, please check your internet connection and try again, if the problem persists, contact the IT wizards"
                self.dataUsageError()
            }
        }
    }
    
    func dataUsageError() {
        dataUsageAlert = UIAlertController(title: dataUsageAlertTitle, message: dataUsageAlertText, preferredStyle: .alert)
        dataUsageAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(dataUsageAlert, animated: true, completion: nil)
    }
    
    
    //------------------------------ ------------------------------ -------------------------------
    
    //------------------------------ Camera Result View -------------------------------
    
    //------------------------------ ------------------------------ -------------------------------

    
    @IBAction func CRVclose(_ sender: UIButton) {
        imageResultViewHeightConstraint.constant = 0
        imageResultViewTopConstraint.constant = 0
        cameraResultView.dropShadowRemove()
        cameraResultView.isHidden = true
        
        UserDefaults.standard.set(nil, forKey: "savedImage")
    }
    
    @IBAction func CRVsendResult(_ sender: UIButton) {
        sendResultAlert = UIAlertController(title: "Send results to consult", message: "this will open an email with the results, enter the recivers mailadress below", preferredStyle: .alert)
        
        sendResultAlert.addTextField { (textField) in
            textField.text = ""
        }
        sendResultAlert.addAction(UIAlertAction(title: "Don't", style: .cancel, handler: nil))
        sendResultAlert.addAction(UIAlertAction(title: "Go", style: .default, handler: { [weak sendResultAlert] (_) in
            let textField = sendResultAlert!.textFields![0]
            if textField.text != "" {
                self.recipientValueMail = textField.text!
                
                let mailComposeViewController = self.configureMailController()
                if MFMailComposeViewController.canSendMail() {
                    self.present(mailComposeViewController, animated: true, completion: nil)
                } else {
                    self.showMailError()
                }
                
            } else {
                let noMailAdressAlert = UIAlertController(title: "No mailadress enterd", message: "Please enter a mailadress and try again", preferredStyle: .alert)
                noMailAdressAlert.addAction(UIAlertAction(title: "Alright", style: .default, handler: { [weak sendResultAlert] (_) in
                    self.present(sendResultAlert!, animated: true, completion: nil)
                }))
                self.present(noMailAdressAlert, animated: true, completion: nil)
            }
        }))
        self.present(sendResultAlert, animated: true, completion: nil)
    }
    
    func configureMailController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        let image = imageResultView.image // Your Image
        let imageData = UIImagePNGRepresentation(image!) ?? nil
        let base64String = imageData?.base64EncodedString() ?? "" // Your String Image
        let mailImage = "<p><img src='data:image/png;base64,\(String(describing: base64String) )'></p>"
        
        mailComposerVC.setToRecipients(["\(recipientValueMail)"])
        mailComposerVC.setSubject("Result of analysis: \(todaysDate)")
    
        mailComposerVC.setMessageBody("<h2 style='color:#3271BB'>Hi</h2><h5>Here is the blightscore from \(todaysDate)</h5></br><p>This image got an score of:</p><h3>\(CRVblightScore.text!)</h3></br><p>The picture that got this result is down below</p><p>Please get back to me, Best regards </br> \(mailImage)", isHTML: true)

        return mailComposerVC
    }
    
    //Fixing an errormessage if the sendMail function don't work
    func showMailError() {
        let sendMailErrorAlert = UIAlertController(title: "Could not send email", message: "Your device cound not send email, please check your settings", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    //------------------------------ ------------------------------ -------------------------------
    
    // ------------------------------ Get data from Joost -----------------------------------------------
    
    //------------------------------ ------------------------------ -------------------------------
    
    

    func getClassifierID() {
        guard let urlGet = URL(string: "https://blighttoaster.eu-gb.mybluemix.net/api/get_classifier_id") else { return }
        
        let session = URLSession.shared
        session.dataTask(with: urlGet) { (data, response, error) in
            if let response = response {
//                print(response)
            }
            if let data = data {
                do {
                    guard let json = try? JSONDecoder().decode(getID.self, from: data) else {
                        print("Error: Couldn't decode data into getID")
                        return
                    }
                    self.sendClassifierId = json.classifier_id
                    print(json.classifier_id)

                } catch {
                    print(error)
                }
            }
        }.resume()
    }

    
    //------------------------------ ------------------------------ -------------------------------
    
    //------------------------------ Alerts View ( seperate viewController ) -----------------------------
    
    //------------------------------ ------------------------------ -------------------------------
    
    @IBAction func alertMoreClick(_ sender: UIButton) {
        if alertsBool == false {
            alertViewHeightConstraint.constant = 500
            alertView.dropShadowRemove()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.alertView.dropShadow()
            }
            alertsBool = true
        } else {
            alertViewHeightConstraint.constant = 250
            alertView.dropShadowRemove()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.alertView.dropShadow()
            }
            alertsBool = false
        }
    }
    
    //------------------------------ ------------------------------ -------------------------------
    
    //------------------------------ News View ( seperate viewController ) -------------------------------
    
    //------------------------------ ------------------------------ -------------------------------
    
    @IBAction func newsMoreClick(_ sender: UIButton) {
        if newsBool == false {
            newsViewHeightConstraint.constant = 500
            newsView.dropShadowRemove()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.newsView.dropShadow()
            }
            newsBool = true
        } else {
            newsViewHeightConstraint.constant = 250
            newsView.dropShadowRemove()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.newsView.dropShadow()
            }
            
            newsBool = false
        }
    }
    
    //------------------------------ ------------------------------ -------------------------------
    
    //------------------------------ Global -------------------------------
    
    //------------------------------ ------------------------------ -------------------------------
    
    //Get todays date
    func getCurrentDateTime() {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        todaysDate = formatter.string(from: Date())
    }
}

extension Data {
    /// Append string to Data
    /// Rather than littering my code with calls to `data(using: .utf8)` to convert `String` values to `Data`, this wraps it in a nice convenient little extension to Data. This defaults to converting using UTF-8.
    /// - parameter string:       The string to be added to the `Data`.
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}

extension UIView {
    func BadgeView() {
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
        self.layoutIfNeeded()
    }
}

extension UIView {
    
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 13)
        layer.shadowRadius = 5
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func dropShadowRemove(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 0
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

extension UIViewController {
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        //spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.6)
        spinnerView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.8)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleToFill) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
