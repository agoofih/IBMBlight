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


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var preScreen: UIView!
    @IBOutlet weak var mainScrollview: UIScrollView!
    @IBOutlet weak var imageResultView: UIImageView!
    @IBOutlet weak var imageResultViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageResultViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var alertTableView: UITableView!
    @IBOutlet weak var newsTableView: UITableView!
    
    var lastImage : UIImage? = nil // 1. ska fixa för att hämta senaste bilden
    var locationManager : CLLocationManager!
    var localtion_lat = 55.611868
    var location_long = 12.977738
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        alertTableView.dataSource = self
        alertTableView.delegate = self
        alertTableView.register(UITableViewCell.self, forCellReuseIdentifier: "alertCell")
        
        newsTableView.dataSource = self
        newsTableView.delegate = self
        newsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "newsCell")
        
//        longPress.addTarget(self, action: "longPressGestureRecognized:")
//        tableView.addGestureRecognizer(longPress)
        
        imageResultViewHeightConstraint.constant = 0
        imageResultViewTopConstraint.constant = 0
        
        locationManager = CLLocationManager()
        
        if CLLocationManager.locationServicesEnabled() {
            //locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        moveMap()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue    .main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            UIView.animate(withDuration: 0.7, animations: {
                self.preScreen.alpha = 0
                //self.preScreen.isHidden = true
            }, completion: nil)
        })
        
        if lastImage != nil { // 1. ska fixa för att hämta senaste bilden
            imageResultViewHeightConstraint.constant = 300
            imageResultViewTopConstraint.constant = 25
            imageResultView.image = lastImage
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        
        localtion_lat = userLocation.coordinate.latitude;
        location_long = userLocation.coordinate.longitude;
        
        print(localtion_lat)
        print(location_long)
        
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
        imageResultViewHeightConstraint.constant = 300
        imageResultViewTopConstraint.constant = 25
        let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        lastImage = pickedImage // 1. ska fixa för att hämta senaste bilden
        imageResultView.image = lastImage // 1. ska fixa för att hämta senaste bilden
        self.dismiss(animated: true, completion: nil)
        print("senaste bilden är: \n \(String(describing:lastImage))")
        
    }
    
    
    
    
    var tempAlert = ["1. alert alert", "2. stuff is happening", "3. What do you want to do with this?", "4. Now it starts to get really seriouse about everything, I think you aught to think hard about this!"]
    
    var tempNews = ["1. BREAKING NEWS! Don't know", "2. Well there has to be something new... No?", "3. Some hackers did something bad. No shit..!", "4. The world ENDS! Bad day for us all. Free icecream!", "5. Something more something less, donno.."]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count : Int = 1
        
        if tableView == self.alertTableView {
            count = tempAlert.count
        }
        
        if tableView == self.newsTableView {
            count = tempNews.count
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell : UITableViewCell?
        
        if tableView == alertTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "alertCell", for: indexPath) as! AlertTableViewCell

            cell!.alertLabel!.text = tempAlert[indexPath.row]

        }
        if tableView == newsTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! NewsTableViewCell
            
            cell!.newsLabel!.text = tempNews[indexPath.row]
           
        }
        
        return cell!
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

