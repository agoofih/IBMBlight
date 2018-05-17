//
//  AlertTableViewCell.swift
//  IBMBlight
//
//  Created by Daniel T. Barwén on 2018-04-03.
//  Copyright © 2018 Daniel T. Barwén. All rights reserved.
//

import UIKit

class AlertTableViewCell: UITableViewCell {
    
    
    @IBOutlet var alertImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageOutlet: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
