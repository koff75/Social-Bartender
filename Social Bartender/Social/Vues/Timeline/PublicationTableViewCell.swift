//
//  PublicationTableViewCell.swift
//  Social Bartender
//
//  Created by nico on 01/12/2015.
//  Copyright © 2015 Nicolas Barthere. All rights reserved.
//

import UIKit
import Parse
import Bond

class PublicationTableViewCell: UITableViewCell {

    // Timeline
    @IBOutlet weak var publicationImageView: UIImageView!
    
    @IBOutlet weak var jaimeButton: UIButton!
    @IBOutlet weak var autreButton: UIButton!
    @IBOutlet weak var aimeLabel: UILabel!
    @IBOutlet weak var aimeImageView: UIImageView!
    // Permet de vider le vieux binding quand un nv arrive
    // Permet d'éviter de charger des images au mauvais endroit dans un défilement se fait vite
    var publicationDisposable: DisposableType?
    var jaimeDisposable: DisposableType?
    
    var publication: Publication? {
        didSet {
            // On supprime l'écoute active des vieux bindings qui ne sont plus affichés
            publicationDisposable?.dispose()
            jaimeDisposable?.dispose()
            
            // Libère la mémoire des publications qui ne sont plus affichées
            if let oldValue = oldValue where oldValue != publication {
                oldValue.image.value = nil
            }
            
            // Vérifie s'il y a qq chose
            if let publication = publication {
                // Place l'image de la publication dans l'imageView
                publicationDisposable = publication.image.bindTo(publicationImageView.bnd_image)
                jaimeDisposable = publication.jaimes.observe({ (valeur: [PFUser]?) -> () in
                    if let valeur = valeur {
                        self.aimeLabel.text = self.listeNomsAligne(valeur)
                        self.jaimeButton.selected = valeur.contains(PFUser.currentUser()!)
                        self.aimeImageView.hidden = (valeur.count == 0)
                    } else {
                        self.aimeLabel.text = ""
                        self.jaimeButton.selected = false
                        self.aimeImageView.hidden = true
                    }
                })
            }
        }
    }
    
    // Génère une virgule sur chaque noms d'utilisateurs qui aime la publication (ex : "Nico1", "Nico2")
    func listeNomsAligne(listeUser: [PFUser]) -> String {
        let listeNoms = listeUser.map { utilisateur in utilisateur.username! }
        let listeSeparateurVirgule = listeNoms.joinWithSeparator(", ")
        return listeSeparateurVirgule
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    
    // ?? ?? ??
    @IBAction func autreButtonTapped(sender: AnyObject) {
        
    }
    @IBAction func jaimeButtonTapped(sender: AnyObject) {
        publication?.attacherJaimePublication(PFUser.currentUser()!)
    }
    

}
