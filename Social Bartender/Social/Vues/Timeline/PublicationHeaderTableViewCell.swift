//
//  PublicationHeaderTableViewCell.swift
//  Social Bartender
//
//  Created by nico on 23/12/2015.
//  Copyright © 2015 Nicolas Barthere. All rights reserved.
//

import UIKit

class PublicationHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var nomLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var publication: Publication? {
        didSet {
            if let publication = publication {
                nomLabel.text = publication.user?.username
                dateLabel.text = publication.createdAt?.shortTimeAgoSinceNow() ?? ""
            }
        }
    }

}
