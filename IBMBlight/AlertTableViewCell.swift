//
//  AlertTableViewCell.swift
//  IBMBlight
//
//  Created by Daniel T. Barwén on 2018-04-03.
//  Copyright © 2018 Daniel T. Barwén. All rights reserved.
//

import UIKit

class AlertTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var alertLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
