//
//  ViewController.swift
//  IBMBlight
//
//  Created by Daniel T. Barwén on 2018-03-22.
//  Copyright © 2018 Daniel T. Barwén. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import MessageUI

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, MFMailComposeViewControllerDelegate {
    
    //Loadingscreen
    @IBOutlet weak var preScreen: UIView!
    
    //Main scrollView
    @IBOutlet weak var mainScrollview: UIScrollView!

    //Top mapView
    @IBOutlet weak var mainMapView: MKMapView!
    
    //CRV = cameraResultView
    @IBOutlet weak var CRVheader: UILabel! //
    @IBOutlet weak var CRVsuggestedInfectionHeader: UILabel! //
    @IBOutlet weak var CRVsuggestedInfectionTypeValue: UILabel! //
    @IBOutlet weak var CRVprababilityHeader: UILabel! //
    @IBOutlet weak var CRVprobabilityDegreeValue: UILabel! //
    @IBOutlet weak var CRVstageHeader: UILabel! //
    @IBOutlet weak var CRVstageValue: UILabel! //
    @IBOutlet weak var CRVsendResult: UIButton! //
    @IBOutlet weak var CRVcloseBtn: UIButton!
    @IBOutlet weak var imageResultView: UIImageView!
    @IBOutlet weak var imageResultViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageResultViewTopConstraint: NSLayoutConstraint!
    
    var locationManager : CLLocationManager!
    
    //Base setup, GPS to IBM Malmö
    var localtion_lat = 55.611868
    var location_long = 12.977738
    
    //Mailadress user puts in befor sending the report
    var recipientValueMail : String = ""
    
    var todaysDate : String = ""
    
    var sendResultAlert = UIAlertController()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
        
        imageResultViewHeightConstraint.constant = 0
        imageResultViewTopConstraint.constant = 0
        imageResultView.isHidden = true
        locationManager = CLLocationManager()
        
        if CLLocationManager.locationServicesEnabled() {
            //locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        moveMap()
        getCurrentDateTime()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            UIView.animate(withDuration: 0.7, animations: {
                self.preScreen.alpha = 0
            }, completion: nil)
        })
        
        //Preload last taken image and show it
        if UserDefaults.standard.value(forKey: "savedImage") == nil {
            print("NUPPNUPP")
        }else{
            print("JUPPJUPP")
            imageResultView.isHidden = false
            imageResultViewHeightConstraint.constant = 300
            imageResultViewTopConstraint.constant = 25
            CRVsetValuesText()
            
            let savedImage = UserDefaults.standard.object(forKey: "savedImage") as! NSData
            imageResultView.image = UIImage(data: savedImage as Data)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        localtion_lat = userLocation.coordinate.latitude
        location_long = userLocation.coordinate.longitude

        moveMap()
    }
    
    func moveMap() {
        let initialLocation = CLLocation(latitude: localtion_lat, longitude: location_long)
        let regionRadius: CLLocationDistance = 500
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate,regionRadius * 2.0, regionRadius * 2.0)
        mainMapView.setRegion(coordinateRegion, animated: true)
    }

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
        imageResultView.isHidden = false
        imageResultViewHeightConstraint.constant = 300
        imageResultViewTopConstraint.constant = 25
        let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        //Encode image for userDefaults
        let imageData : NSData = UIImagePNGRepresentation(pickedImage)! as NSData
        
        //Save image userDefaults
        UserDefaults.standard.set(imageData, forKey: "savedImage")
        
        //Decode image and display
        let activeImage = UserDefaults.standard.object(forKey: "savedImage") as! NSData
        imageResultView.image = UIImage(data: activeImage as Data)

        CRVsetValuesText()
        self.dismiss(animated: true, completion: nil)
    }
    
    func CRVsetValuesText(){
        CRVheader.text = "Result of analysis"
        CRVsuggestedInfectionHeader.text = "Suggested infection:"
        CRVsuggestedInfectionTypeValue.text = "infectionTypeValue"
        CRVprababilityHeader.text = "Propability of infection:"
        CRVprobabilityDegreeValue.text = "degreeValue"
        CRVstageHeader.text = "Stage of infection:"
        CRVstageValue.text = "stageValue"
        CRVsendResult.setTitle("Send result as email", for: .normal)
        CRVcloseBtn.setTitle("X", for: .normal)
    }
    
    func CRVresetValues() {
        CRVheader.text = ""
        CRVsuggestedInfectionHeader.text = ""
        CRVsuggestedInfectionTypeValue.text = ""
        CRVprababilityHeader.text = ""
        CRVprobabilityDegreeValue.text = ""
        CRVstageHeader.text = ""
        CRVstageValue.text = ""
        CRVsendResult.setTitle("", for: .normal)
        CRVcloseBtn.setTitle("", for: .normal)
    }
    
    
    @IBAction func CRVclose(_ sender: UIButton) {
        CRVresetValues()
        imageResultViewHeightConstraint.constant = 0
        imageResultViewTopConstraint.constant = 0
        imageResultView.isHidden = true
        UserDefaults.standard.set(nil, forKey: "savedImage")
    }
    
    @IBAction func CRVsendResult(_ sender: UIButton) {
        sendResultAlert = UIAlertController(title: "Clickydiclick", message: "this will open an email with the results, enter the recivers mailadress below", preferredStyle: .alert)
        
        sendResultAlert.addTextField { (textField) in
            textField.text = ""
        }
        sendResultAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        sendResultAlert.addAction(UIAlertAction(title: "Go", style: .default, handler: { [weak sendResultAlert] (_) in
            let textField = sendResultAlert!.textFields![0] // Force unwrapping because we know it exists.
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
                print("Bitch")
            }
            
        }))
        
        self.present(sendResultAlert, animated: true, completion: nil)
    }
    
    func configureMailController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["\(recipientValueMail)"])
        //mailComposerVC.setToRecipients(["awd@awd.se"])
        mailComposerVC.setSubject("Result of analysis: \(todaysDate)")
        mailComposerVC.setMessageBody("<h2>Hi</h2></br><h4>Here is the \(CRVheader.text!) from \(todaysDate)</h4><p>\(CRVsuggestedInfectionHeader.text!)</p><h6>\(CRVsuggestedInfectionTypeValue.text!)</h6></br><p>\(CRVprababilityHeader.text!)</p><h6>\(CRVsuggestedInfectionTypeValue.text!)</h6><p>\(CRVstageHeader.text!)</p><h6>\(CRVstageValue.text!)</h6></br><p>The picture that got this result is in the attatchment</p><p>Please get back to me, Best regards", isHTML: true)
        
       // mailComposerVC.addAttachmentData(<#T##attachment: Data##Data#>, mimeType: <#T##String#>, fileName: <#T##String#>)
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
    
    //Get todays date
    func getCurrentDateTime() {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        todaysDate = formatter.string(from: Date())
        print(todaysDate)
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

