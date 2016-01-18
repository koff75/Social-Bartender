//
//  ClassementTableViewCell.swift
//  Social Bartender
//
//  Created by nico on 18/01/2016.
//  Copyright © 2016 Nicolas Barthere. All rights reserved.
//

import UIKit

class ClassementTableViewCell: UITableViewCell {

    @IBOutlet weak var nomCocktailLabel: UILabel!
    @IBOutlet weak var compteurLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
