//
//  CustomTableViewCell.swift
//  Social Bartender
//
//  Created by nico on 09/11/2015.
//  Copyright © 2015 Nicolas Barthere. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    // Nom du menu dans le bandeau de gauche    
    @IBOutlet weak var menuItemLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
