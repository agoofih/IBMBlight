//
//  AlertViewController.swift
//  IBMBlight
//
//  Created by Daniel T. Barwén on 2018-04-03.
//  Copyright © 2018 Daniel T. Barwén. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController, UITableViewDelegate, UITableViewDataSource { 

    
    @IBOutlet weak var alertTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        alertTableView.register(AlertTableViewCell.self, forCellReuseIdentifier: "alertCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var tempAlert = ["1. alert alert", "2. stuff is happening", "3. What do you want to do with this?", "4. Now it starts to get really seriouse about everything, I think you aught to think hard about this!"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempAlert.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "alertCell", for: indexPath) as! AlertTableViewCell
        
        cell.alertLabel?.text = tempAlert[indexPath.row]
        tableView.separatorStyle = .none
        
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
