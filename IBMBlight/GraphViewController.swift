//
//  GraphViewController.swift
//  IBMBlight
//
//  Created by Daniel T. Barwén on 2018-05-08.
//  Copyright © 2018 Daniel T. Barwén. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import Charts

class GraphViewController: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet var lineChartView: LineChartView!
    
    let locationManager = CLLocationManager()
    var location : CLLocation?
    var locLat : String = ""
    var locLng : String = ""
    var jsonUrlString : String = ""
    var url = URL(string: "")
    
    //Used to update position only ones
    var checker = 0

    //variables to check so the data is not nil
    var tSave : Double = 0.0
    var rSave : Int = 0
    var dateSave : Double = 0.0
    var blightSave : Double = 0.0

    
    //Recive
    var rLiveBlightScore : [Double] = []
    var rLiveR : [Int] = []
    var rLiveT : [Double] = []
    var rLiveDate : [Double] = []
    
    var poundBool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func updateGraph(){
        
        //this is the Arrays that will eventually be displayed on the graph.
        var lineChartEntry  = [ChartDataEntry]()
        var lineChartEntry2  = [ChartDataEntry]()
        var lineChartEntry3  = [ChartDataEntry]()

        //here is the for loop
        var prevdate = 0.0
        
        for i in 0 ..< rLiveBlightScore.count {

            let daten = rLiveDate[i]
            let calc = daten / 1000
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            dateFormatter.locale = Locale(identifier: "sv_SV")
            
            if((calc - prevdate) > (6 * 3600)) && rLiveBlightScore[i] != -100.0 && rLiveR[i] != -100 && rLiveT[i] != -100.0 {
                
                let value = ChartDataEntry(x: Double(calc), y: rLiveBlightScore[i])
                let value2 = ChartDataEntry(x: Double(Int(calc)), y: Double(rLiveR[i]))
                let value3 = ChartDataEntry(x: Double(calc), y: rLiveT[i])
        
                lineChartEntry.append(value)
                lineChartEntry2.append(value2)
                lineChartEntry3.append(value3)
                
                prevdate = calc

            }
            
        }
        
        //Clear up the arrays after data is added
        rLiveR.removeAll()
        rLiveT.removeAll()
        rLiveDate.removeAll()
        rLiveBlightScore.removeAll()
        
        //Here we convert lineChartEntry to a LineChartDataSet
        let blightLine = LineChartDataSet(values: lineChartEntry, label: "Blight probability in %")
        let humidityLine = LineChartDataSet(values: lineChartEntry2, label: "Humidity in %")
        let tempLine = LineChartDataSet(values: lineChartEntry3, label: "Temperature in °C")
        
        //Some Styling for the chart lines
        blightLine.colors = [NSUIColor.orange] //Sets the colour to blue
        blightLine.circleHoleColor = UIColor.orange
        blightLine.circleColors = [NSUIColor.clear] //Sets the colour to blue
        blightLine.lineWidth = 2
        
        humidityLine.colors = [NSUIColor.blue]
        humidityLine.circleHoleColor = UIColor.blue
        humidityLine.circleColors = [NSUIColor.clear]
        humidityLine.lineWidth = 1.5
        
        tempLine.colors = [NSUIColor.red]
        tempLine.circleHoleColor = UIColor.red
        tempLine.circleColors = [NSUIColor.clear]
        tempLine.lineWidth = 1.5

        //This is the object that will be added to the chart
        let data = LineChartData()
        
        //Adds the lines to the dataSet
        data.addDataSet(blightLine)
        data.addDataSet(humidityLine)
        data.addDataSet(tempLine)
        
        //finally - it adds the chart data to the chart and causes an update
        lineChartView.data = data
        
        lineChartView.chartDescription?.text = ""
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.enabled = false
        lineChartView.extraBottomOffset = 10
        lineChartView.extraTopOffset = 60
        lineChartView.extraLeftOffset = 10
        lineChartView.extraRightOffset = 30
        
        let xAxis = lineChartView.xAxis
        xAxis.labelFont = .systemFont(ofSize: 10, weight: .light)
        xAxis.centerAxisLabelsEnabled = true
        xAxis.granularity = 3600
        xAxis.valueFormatter = DateValueFormatter()
        
        lineChartView.reloadInputViews()
    }
    
    
    @IBAction func poundButton(_ sender: Any) {
        let xAxis = lineChartView.xAxis
        if poundBool == false {
            xAxis.drawGridLinesEnabled = true
            lineChartView.leftAxis.drawGridLinesEnabled = true
            poundBool = true
        } else {
            xAxis.drawGridLinesEnabled = false
            lineChartView.leftAxis.drawGridLinesEnabled = false
            poundBool = false
        }
        lineChartView.notifyDataSetChanged()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        ////Live code for location instead of dummy, Use below instead for ownPin in forcast.
        location = locations[0]
        locLat = "\(location!.coordinate.latitude)"
        locLng = "\(location!.coordinate.longitude)"
        jsonUrlString = "http://blighttoaster.eu-gb.mybluemix.net/api/weather?lat=\(locLat)&lng=\(locLng)"
        url = URL(string: jsonUrlString)
        
        if checker == 0 {
            getFullGraphDataCheck()
            checker += 1
        }
        manager.stopUpdatingLocation()
    }
    
    func nullToNil(value : Any?) -> Any? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }

    func getFullGraphDataCheck() {
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "GET"
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                DispatchQueue.main.async {
                    do {
                        if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                            
                            if let topLevel = jsonObj!.value(forKey:"datelist") as? NSArray {
                                
                                
                                
                                if let dateTime = topLevel.value(forKey:"DateTime") as? NSArray {
                                    
                                    for item in dateTime {
                                        self.rLiveDate.append(item as! Double)
                                    }
                                    
                                } else {
                                    print("WRONG DateTime ", "Error : ", error ?? "")
                                }
                                
                                
                                if let blightScore = topLevel.value(forKey: "blightscore") as? NSArray {
                                    
                                    for var item in blightScore {
                                        let tempNil = self.nullToNil(value: item)
                                        if tempNil == nil {
                                            item = -100.0
                                        }
                                        self.rLiveBlightScore.append(item as! Double)
                                    }
                                    
                                } else {
                                    print("WRONG blightscore ", "Error : ", error as Any)
                                }
                                
//                                print("rLiveBlightScore in json loop: ", self.rLiveBlightScore.count)
                                
                                if let temp = topLevel.value(forKey: "t") as? NSArray {
                                    
                                    for var item in temp {
                                        let tempNil = self.nullToNil(value: item)
                                        if tempNil == nil {
                                            item = -100.0
                                        }
                                        self.rLiveT.append(item as! Double)
                                    }
                                    
                                } else {
                                    print("WRONG temp (t)", "Error : ", error as Any)
                                }
                                
                                if let humid = topLevel.value(forKey: "r") as? NSArray {
                                    
                                    for var item in humid {
                                        let tempNil = self.nullToNil(value: item)
                                        if tempNil == nil {
                                            item = -100
                                        }
                                        self.rLiveR.append(item as! Int)
                                    }
                                    
                                    
                                    
                                } else {
                                    print("WRONG humidity (r)", "Error : ", error as Any)
                                }
                            } else {
                                print("WRONG 3")
                            }
                        } else {
                            print("WRONG 2")
                        }
                    } catch {
                        print("WRONG 1")
                    }
                }
                DispatchQueue.main.async {
                    self.updateGraph()
                }
                
            }}.resume()
        
    }

    
}
