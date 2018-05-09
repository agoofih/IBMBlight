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
    var checker = 0
    
    //Recive
    var rLiveBlightScore : [Double] = []
    var rLiveR : [Int] = []
    var rLiveT : [Double] = []
    var rLiveDate : [Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func updateGraph(){
        var lineChartEntry  = [ChartDataEntry]() //this is the Array that will eventually be displayed on the graph.
        var lineChartEntry2  = [ChartDataEntry]()
        var lineChartEntry3  = [ChartDataEntry]()
        
        //here is the for loop
        print("Blightscore count- UpdateGraph: ", rLiveBlightScore.count)
        for i in 0 ..< rLiveBlightScore.count {
        
            var daten = rLiveDate[i]
            let calc = daten / 1000
            let date = Date(timeIntervalSince1970: calc) // 2018-05-14 05:00:00 +0000 ex.
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            dateFormatter.locale = Locale(identifier: "sv_SV")
            print(dateFormatter.string(from: date)) // Jan 2, 2001
            
            let value = ChartDataEntry(x: Double(daten), y: rLiveBlightScore[i])
            let value2 = ChartDataEntry(x: Double(Int(daten)), y: Double(rLiveR[i])) // here we set the X and Y status in a data chart entry
            let value3 = ChartDataEntry(x: Double(daten), y: rLiveT[i])
            
            lineChartEntry.append(value) // here we add it to the data set
            lineChartEntry2.append(value2) // here we add it to the data set
            lineChartEntry3.append(value3)
        }
        
        let blightLine = LineChartDataSet(values: lineChartEntry, label: "BlightScore")
        let humidityLine = LineChartDataSet(values: lineChartEntry2, label: "Humidity") //Here we convert lineChartEntry to a LineChartDataSet
        let tempLine = LineChartDataSet(values: lineChartEntry3, label: "Temperature")
        
        blightLine.colors = [NSUIColor.blue] //Sets the colour to blue
        blightLine.circleColors = [NSUIColor.clear] //Sets the colour to blue
        blightLine.circleHoleColor = UIColor.blue
        blightLine.lineWidth = 1.5
        humidityLine.colors = [NSUIColor.red]
        humidityLine.circleHoleColor = UIColor.red
        humidityLine.circleColors = [NSUIColor.clear]
        humidityLine.lineWidth = 1.5
        tempLine.colors = [NSUIColor.green]
        tempLine.circleHoleColor = UIColor.green
        tempLine.circleColors = [NSUIColor.clear]
        tempLine.lineWidth = 1.5
        
        let data = LineChartData() //This is the object that will be added to the chart
        
        data.addDataSet(blightLine) //Adds the line to the dataSet
        data.addDataSet(humidityLine)
        data.addDataSet(tempLine)
        
        lineChartView.data = data //finally - it adds the chart data to the chart and causes an update
        
        lineChartView.chartDescription?.text = "Piuni" // Here we set the description for the graph
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.enabled = false
        lineChartView.extraBottomOffset = 15
        lineChartView.extraTopOffset = 30
        lineChartView.extraLeftOffset = 10
        lineChartView.extraRightOffset = 30
        
        lineChartView.reloadInputViews()
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        ////Live code for location instead of dummy, Use below instead for ownPin in forcast.
        location = locations[0]
        locLat = "\(location!.coordinate.latitude)"
        locLng = "\(location!.coordinate.longitude)"
        jsonUrlString = "http://blighttoaster.eu-gb.mybluemix.net/api/weather?lat=\(locLat)&lng=\(locLng)"
        url = URL(string: jsonUrlString)
        
        //print("Graph lat lng : \(locLat) , \(locLng)")
        if checker == 0 {
            getGraphData2()
            checker += 1
            print("CHECKER \(checker)")
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
    
    func getGraphData2() {
 
        var request = URLRequest(url: url!)
        
        request.httpMethod = "GET"
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                DispatchQueue.main.async {
                    do {
                        if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                            
                            if let topLevel = jsonObj!.value(forKey:"datelist") as? NSArray {

                                var dateCounter = 0
                                var blightCounter = 0
                                var tempCounter = 0
                                var humidCounter = 0
     
                                if let dateTime = topLevel.value(forKey:"DateTime") as? NSArray {
                                        
                                    for item in dateTime {
                                        dateCounter += 1
                                        
                                        if dateCounter == 6 {
                                            self.rLiveDate.append(item as! Double)
                                            dateCounter = 0
                                        }
                                    }
                                    
                                } else {
                                    print("WRONG DateTime ", "Error : ", error ?? "")
                                }
                                
                                if let blightScore = topLevel.value(forKey: "blightscore") as? NSArray {
                                        
                                    for item in blightScore {
                                        blightCounter += 1
                                        
                                        if blightCounter == 6 {
                                            self.rLiveBlightScore.append(item as! Double)
                                            blightCounter = 0
                                        }
                                        
                                    }
//                                    print(self.rLiveBlightScore)
                                    print("Blightscore count inside: ", self.rLiveBlightScore.count)
                                    
                                } else {
                                    print("WRONG blightscore ", "Error : ", error)
                                }
                                
                                if let temp = topLevel.value(forKey: "t") as? NSArray {
                                    
                                    for var item in temp {
                                        tempCounter += 1

                                        if tempCounter == 6 {
                                            let tempNil = self.nullToNil(value: item)
                                            if tempNil == nil {
                                                item = -10.0
                                            }
                                            self.rLiveT.append(item as! Double)
                                            tempCounter = 0
                                        }
                                    }
                                    
                                } else {
                                    print("WRONG temp (t)", "Error : ", error)
                                }
                                
                                if let humid = topLevel.value(forKey: "r") as? NSArray {
                                    
                                    for var item in humid {
                                        humidCounter += 1
                                        
                                        if humidCounter == 6 {
                                            let tempNil = self.nullToNil(value: item)
                                            if tempNil == nil {
                                                item = -10
                                            }
                                            self.rLiveR.append(item as! Int)
                                            humidCounter = 0
                                        }
                                    }
                                    
                                } else {
                                    print("WRONG temp (t)", "Error : ", error)
                                }
                                print("Blightscore count inside2: ", self.rLiveBlightScore.count)
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
                print("Blightscore count inside3: ", self.rLiveBlightScore.count)
                DispatchQueue.main.async {
                    self.updateGraph()
                }
                
            }}.resume()
        
    }
}
