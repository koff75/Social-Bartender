//
//  AjouterAmiViewController.swift
//  Social Bartender
//
//  Created by nico on 12/11/2015.
//  Copyright © 2015 Nicolas Barthere. All rights reserved.
//

import UIKit
import Parse

class AjouterAmiViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var maTableView: UITableView!
    @IBOutlet weak var maSearchBar: UISearchBar!
    var resultatRecherche: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Va nous retourner le nombre d'éléments présents dans Parse
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return resultatRecherche.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let maCellule = tableView.dequeueReusableCellWithIdentifier("MaCellule", forIndexPath: indexPath) as! UITableViewCell
        // On place le contenu du résultat de recherche dans la cellule
        maCellule.textLabel?.text = resultatRecherche[indexPath.row]
        return maCellule
    }
    
    // Appelée quand il y a un click sur une cellule de la tableview
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        // Cache le clavier
        maSearchBar.resignFirstResponder()
    }
    
    // Appellée quand le bouton Rechercher du clavier est appelé
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        maSearchBar.resignFirstResponder()
        var requetePrenom = PFQuery(className: "_User")
        requetePrenom.whereKey("prenom_utilisateur", containsString: searchBar.text)
        var requeteNom = PFQuery(className: "_User")
        requeteNom.whereKey("nom_utilisateur", containsString: searchBar.text)
        var requete = PFQuery.orQueryWithSubqueries([requetePrenom,requeteNom])
        

        requete.findObjectsInBackgroundWithBlock { (resultat: [PFObject]?, erreur: NSError?) -> Void in
            if erreur != nil {
                // Popup alerte
                let messageUtilisateur = erreur!.localizedDescription
                if #available(iOS 8.0, *) {
                    var alerte = UIAlertController(title: "Attention", message: messageUtilisateur, preferredStyle: UIAlertControllerStyle.Alert)
                    let okBouton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                    alerte.addAction(okBouton)
                    self.presentViewController(alerte, animated: true, completion: nil)
                    return
                } else {
                    // Fallback on earlier versions
                    let alerte = UIAlertView()
                    alerte.title = "Attention"
                    alerte.message = messageUtilisateur
                    alerte.addButtonWithTitle("Ok")
                    alerte.show()
                    return
                }
            }
            
            if let objets = resultat as [PFObject]? {
                // On efface d'abord le tableau de resultats
                self.resultatRecherche.removeAll(keepCapacity: false)
                
                // On parcours les objets
                for objet in objets {
                    let prenom = objet.objectForKey("prenom_utilisateur") as! String
                    let nom = objet.objectForKey("nom_utilisateur") as! String
                    let complet = prenom + " " + nom
                    
                    // On place dans le tableau de resultats les noms complets
                    self.resultatRecherche.append(complet)
                }
                
                // Rechargement
                dispatch_async(dispatch_get_main_queue()) {
                    self.maTableView.reloadData()
                    // Enlève le clavier
                    self.maSearchBar.resignFirstResponder()
                }
            }
        }
    }
    
    // Appellée quand le bouton Annuler du clavier est appelé
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        // Effacer le clavier keyboard
        maSearchBar.resignFirstResponder()
        maSearchBar.text = ""
    }

    @IBAction func rafraichirButtonTapped(sender: AnyObject) {
        maSearchBar.resignFirstResponder()
        maSearchBar.text = ""
        self.resultatRecherche.removeAll(keepCapacity: false)
        self.maTableView.reloadData()
    }
}