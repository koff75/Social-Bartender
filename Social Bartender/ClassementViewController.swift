//
//  ClassementViewController.swift
//  Social Bartender
//
//  Created by nico on 18/01/2016.
//  Copyright © 2016 Nicolas Barthere. All rights reserved.
//

import UIKit

class ClassementViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var cocktailObjet1 = [PFObject]()
    var cocktailObjet2 = [PFObject]()


    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        // Charge les données dans la tableView quand elle aparait
        chargementClassementTableView()
    }
    
    /* Va charger la vue pour Rechercher un cocktail (cocktail_base) avec la liste de tous les cocktails */
    func chargementClassementTableView() {
        // Cocktail Base : 
        
        // Construit un objet requête Parse
        let query1 = PFQuery(className:"Cocktails_base")
        query1.orderByDescending("nb_conso_cocktail")
        // Extrait les données de la plateforme Parse
        query1.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error:NSError?) -> Void in
            // S'il n'y a pas de problème
            if error == nil {
                // Vide les données existantes
                self.cocktailObjet1.removeAll(keepCapacity: true)
                
                // Ajout de l'objet cocktail dans notre tableau "PAS SUR DU !"
                if let objects = objects as? [PFObject]! {
                    self.cocktailObjet1 = Array(objects.generate())
                }

                // Rechargement de nos données dans notre collectionView
                self.tableView.reloadData()

            } else {
                // S'il y a une erreur, on la log
                print("Erreurr: \(error!) \(error!.userInfo)")
            }
        }
        
        // Cocktail Perso :
        let query2 = PFQuery(className:"Cocktails_perso")
        query2.orderByDescending("nb_conso_cocktail")
        query2.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error:NSError?) -> Void in
            if error == nil {
                self.cocktailObjet2.removeAll(keepCapacity: true)
                if let objects = objects as? [PFObject]! {
                    self.cocktailObjet2 = Array(objects.generate())
                }
                self.tableView.reloadData()
            } else {
                // S'il y a une erreur, on la log
                print("Erreurr: \(error!) \(error!.userInfo)")
            }
        }
        
    }
    
    // Va nous retourner le nombre d'éléments présents dans Parse
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        if(self.segmentedControl.selectedSegmentIndex == 0) {
            return cocktailObjet1.count
        } else {
            return cocktailObjet2.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("maCellule", forIndexPath: indexPath) as! ClassementTableViewCell
        if(self.segmentedControl.selectedSegmentIndex == 0) {
            // Affichage du nom du cocktail
            if let value = cocktailObjet1[indexPath.row]["nom_cocktail"] as? String {
                cell.nomCocktailLabel.text = value
                cell.compteurLabel.text = String(indexPath.row+1)
            }
            return cell
        } else {
            // Affichage du nom du cocktail
            if let value = cocktailObjet2[indexPath.row]["nom_cocktail"] as? String {
                cell.nomCocktailLabel.text = value
                cell.compteurLabel.text = String(indexPath.row+1)
            }
            return cell
        }
    }
    
    // Suivant l'onglet sélectionné, on recharge la table avec les bonnes données
    @IBAction func segmentedControlTapped(sender: AnyObject) {
        if(self.segmentedControl.selectedSegmentIndex == 0) {
            tableView.reloadData()
        } else {
            tableView.reloadData()
        }
    }
    
    
    /* Cablement du segue pour le détail des cocktails */
    
    // Exécute la cellule sélectionnée de la collectionView
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(self.segmentedControl.selectedSegmentIndex == 0) {
            let currentObject = cocktailObjet1[indexPath.row]
            performSegueWithIdentifier("segueViewController", sender: currentObject)
        } else {
            let currentObject = cocktailObjet2[indexPath.row]
            performSegueWithIdentifier("segueViewController", sender: currentObject)
        }
    }
    
    
    // Dans la storyboard, preparation avec la navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(self.segmentedControl.selectedSegmentIndex == 0) {
            
            // Si une cellule a été selectionnée dans la collectionView - Mettre currentOject a select
            var currentObject : PFObject?
            if let cocktails = sender as? PFObject{
                currentObject = sender as? PFObject
            } else {
                // Si pas de cellule selectionnée - Doit être un nouveau cocktail enregistré
                currentObject = PFObject(className:"Cocktails_base")
            }
            // Reçoit un évènement dans la prochaine storyboard controller et place le currentObject à prêt pour la méthode viewDidLoad
            var detailScene = segue.destinationViewController as! DetailCocktailViewController
            // Appel de la méthode currentObject présente dans DetailCocktailViewController
            detailScene.currentObject = (currentObject)
        } else {
            // Si une cellule a été selectionnée dans la collectionView - Mettre currentOject a select
            var currentObject : PFObject?
            if let cocktails = sender as? PFObject{
                currentObject = sender as? PFObject
            } else {
                // Si pas de cellule selectionnée - Doit être un nouveau cocktail enregistré
                currentObject = PFObject(className:"Cocktails_perso")
            }
            // Reçoit un évènement dans la prochaine storyboard controller et place le currentObject à prêt pour la méthode viewDidLoad
            var detailScene = segue.destinationViewController as! DetailCocktailViewController
            // Appel de la méthode currentObject présente dans DetailCocktailViewController
            detailScene.currentObject = (currentObject)
            
        }
    }
    
    

}
