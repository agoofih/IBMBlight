//
//  NewsViewController.swift
//  IBMBlight
//
//  Created by Daniel T. Barwén on 2018-04-03.
//  Copyright © 2018 Daniel T. Barwén. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var newsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        newsTableView.register(NewsTableViewCell.self, forCellReuseIdentifier: "newsCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var tempNews = ["1. BREAKING NEWS! Don't know", "2. Well there has to be something new... No?", "3. Some hackers did something bad. No shit..!", "4. The world ENDS! Bad day for us all. Free icecream!", "5. Something more something less, donno..,", "6. Ohh well aliens won, new bosses.. Most other people dead.. maybe it's MY TIME TO SHINE!! Take the good with the bad"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempNews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! NewsTableViewCell
        
        tableView.separatorStyle = .none
        if cell.newsLabel != nil {
             cell.newsLabel.text = tempNews[indexPath.row]
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
