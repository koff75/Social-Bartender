//
//  SuivreTableViewCell.swift
//  Social Bartender
//
//  Created by nico on 21/12/2015.
//  Copyright © 2015 Nicolas Barthere. All rights reserved.
//

import UIKit
import Parse

protocol SuivreTableViewCellDelegate: class {
    func cell(cell: SuivreTableViewCell, didSelectFollowUser user: PFUser)
    func cell(cell: SuivreTableViewCell, didSelectUnfollowUser user: PFUser)
}


class SuivreTableViewCell: UITableViewCell {
    
    @IBOutlet weak var suivreButton: UIButton!
    @IBOutlet weak var nomLabel: UILabel!
    weak var delegate: SuivreTableViewCellDelegate?

    
    var utilisateur: PFUser? {
        didSet {
            nomLabel.text = utilisateur?.username
        }
    }
    
    var peutSuivre: Bool? = true {
        didSet {
            /*
            Change l'état du bouton suivre si ou non, il est possible de
            suivre un utilisateur
            */
            if let peutSuivre = peutSuivre {
                suivreButton.selected = !peutSuivre
            }
        }
    }
    
    @IBAction func suivreButtonTapped(sender: AnyObject) {
        if let peutSuivre = peutSuivre where peutSuivre == true {
            delegate?.cell(self, didSelectFollowUser: utilisateur!)
            self.peutSuivre = false
        } else {
            delegate?.cell(self, didSelectUnfollowUser: utilisateur!)
            self.peutSuivre = true
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
