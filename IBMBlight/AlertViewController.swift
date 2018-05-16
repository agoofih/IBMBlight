//
//  AlertViewController.swift
//  IBMBlight
//
//  Created by Daniel T. Barwén on 2018-04-03.
//  Copyright © 2018 Daniel T. Barwén. All rights reserved.
//

import UIKit

struct Feed : Decodable {
    var date : String?
    var description : String?
    var id : Int?
    var is_alert : Bool?
    var lat : Double?
    var lng : Double?
    var title : String?
}

struct TopLevel : Decodable {
    var alerts : [Feed]
}

class AlertViewController: UIViewController, UITableViewDelegate, UITableViewDataSource { 

    
    @IBOutlet weak var alertTableView: UITableView!
    private var feedList = [Feed]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        alertTableView.register(AlertTableViewCell.self, forCellReuseIdentifier: "alertCell")
        getAlertsAndNews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func getAlertsAndNews() {
        print("RUNNING")
        
        let jsonUrlString = "http://blighttoaster.eu-gb.mybluemix.net/api/get_news_and_alerts"
        guard let url = URL(string: jsonUrlString) else { return }
        
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            if response != nil {
//                print(response)
            }
            
            if error != nil {
                print(error)
            }
            
            guard let data = data else { return }
            
            do {
                let alerts = try JSONDecoder().decode(TopLevel.self, from: data)
                
                self.feedList = alerts.alerts
                
//                print("Json decode : ",self.feedList)
//                DispatchQueue.main.async {
//                    print("Count123: ",self.feedList.count)
////                    self.alertTableView.reloadData()
//                }
                
                
//                for run in alerts.alerts {
//
//                    self.feed.append(run)
//
//                    print(self.feed)
//
//                    if run.id != nil {
//                        print(run.id!)
//                    }
//                    if run.title != nil {
//                        print(run.title!)
//                    }
//                    if run.date != nil {
//                        print(run.date!)
//                    }
//                    if run.description != nil {
//                        print(run.description!)
//                    }
//                    if run.is_alert != nil {
//                        print(run.is_alert!)
//                    }
//                    if run.lat != nil {
//                        print(run.lat!)
//                    }
//                    if run.lng != nil {
//                        print(run.lng!)
//                    }
//                    print("----------------------")
//
//                }

                
            } catch {
             print("bupp", error)
            }
            DispatchQueue.main.async {
//                print("reload")
                self.alertTableView.reloadData()
            }
        }.resume()
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 155
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "alertCell", for: indexPath) as! AlertTableViewCell
        
//        print("cell for row at feedlist ", feedList.count)
        tableView.separatorStyle = .none

        cell.titleLabel.text = ""
        cell.descriptionLabel.text = ""
        cell.dateLabel.text = ""
        
        if feedList[indexPath.row].title != nil {
            cell.titleLabel.text = feedList[indexPath.row].title
        }
        if feedList[indexPath.row].description != nil {
            cell.descriptionLabel.text = feedList[indexPath.row].description
        }
        if feedList[indexPath.row].date != nil {
            cell.dateLabel.text = feedList[indexPath.row].date
        }
        
        
        
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
