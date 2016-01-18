//
//  PagePrincipaleViewController.swift
//  Social Bartender
//
//  Created by nico on 07/11/2015.
//  Copyright © 2015 Nicolas Barthere. All rights reserved.
//

import UIKit
import Parse
import AVFoundation


var cocktails = [PFObject]()

class RechercherCocktailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    
    @IBOutlet weak var rechercherCollectionView: UICollectionView!
    @IBOutlet weak var selectionCollectionView: UICollectionView!
    
    

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Retaille la taille des éléments de la CollectioViewResize dans la grille pour avoir 3 colonnes
        /*let cellWidth = ((UIScreen.mainScreen().bounds.width) - 32 - 30 ) / 3
        let cellLayout = rechercherCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        cellLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)*/

        //collectionView!.backgroundColor = UIColor.clearColor()
        //collectionView!.contentInset = UIEdgeInsets(top: 23, left: 5, bottom: 10, right: 5)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    @IBAction func MenuButtonItem(sender: AnyObject) {
        // Active le panneau de Gauche (Menu)
        var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.contenuDrawer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        // Charge les données dans la collectionView quand elle aparait
        
        // Si la vue "rechercherCollectionView" est sélectionnée, on charge "chargementDonneesRechercherCollectionView"
        //if(rechercherCollectionView != nil){chargementDonneesRechercherCollectionView()}
       chargementDonneesRechercherCollectionView()
    }
    
    /* Va charger la vue pour Rechercher un cocktail (cocktail_base) avec la liste de tous les cocktails */
    func chargementDonneesRechercherCollectionView() {
        // Construit un objet requête Parse
        var query = PFQuery(className:"Cocktails_base")
        
        // /!\ Si la vue Rechercher est activée, on vérifie la searchBar
        // /!\ Sinon c'est que vue Selection est activée, alors on ne charge QUE la selection de cocktails
        if(rechercherCollectionView != nil){
            // Vérifie s'il y a un élément à rechercher
            if searchBar.text != "" {
                query.whereKey("nom_cocktail", matchesRegex: searchBar.text!, modifiers: "i")
            }
        }
        else {
            query.whereKey("selection_cocktail", equalTo: true)
        }

        // Extrait les données de la plateforme Parse
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error:NSError?) -> Void in
            
            // S'il n'y a pas de problème
            if error == nil {
                
                // Vide les données existantes
                cocktails.removeAll(keepCapacity: true)
                
                // Ajout de l'objet cocktail dans notre tableau "PAS SUR DU !"
                if let objects = objects as? [PFObject]! {
                    cocktails = Array(objects.generate())
                }
                
                // Rechargement de nos données dans notre collectionView
                if(self.rechercherCollectionView != nil){
                    self.rechercherCollectionView.reloadData()
                }
                else {
                    self.selectionCollectionView.reloadData()
                }
                
                
            } else {
                // S'il y a une erreur, on la log
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cocktails.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if (self.rechercherCollectionView != nil) {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MaCellule", forIndexPath: indexPath) as! RechercherCocktailCollectionViewCell
            // Affichage du nom du cocktail
            if let value = cocktails[indexPath.row]["nom_cocktail"] as? String {
                cell.celluleLabel.text = value
            }
            
            // Affichage du flag "initial" image
            var initialThumbnail = UIImage(named: "photo_cocktail")
            cell.celluleImageView.image = initialThumbnail
            
            // Recupère le flag "final" image si il existe
            if let value = cocktails[indexPath.row]["photo_cocktail"] as? PFFile {
                let finalImage = cocktails[indexPath.row]["photo_cocktail"] as? PFFile
                finalImage!.getDataInBackgroundWithBlock {
                    (imageData: NSData?, error: NSError?) -> Void in
                    if error == nil {
                        if let imageData = imageData {
                            cell.celluleImageView.image = UIImage(data:imageData)
                            cell.celluleImageView.contentMode = .ScaleAspectFill
                        }
                    }
                }
            }
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MaCellule", forIndexPath: indexPath) as! RechercherCocktailCollectionViewCell
            // Affichage du nom du cocktail
            if let value = cocktails[indexPath.row]["nom_cocktail"] as? String {
                cell.selectionCelluleLabel.text = value
            }
            
            // Affichage du flag "initial" image
            var initialThumbnail = UIImage(named: "photo_cocktail")
            cell.selectionCelluleImageView.image = initialThumbnail
            
            // Recupère le flag "final" image si il existe
            if let value = cocktails[indexPath.row]["photo_cocktail"] as? PFFile {
                let finalImage = cocktails[indexPath.row]["photo_cocktail"] as? PFFile
                finalImage!.getDataInBackgroundWithBlock {
                    (imageData: NSData?, error: NSError?) -> Void in
                    if error == nil {
                        if let imageData = imageData {
                            cell.selectionCelluleImageView.image = UIImage(data:imageData)
                            cell.selectionCelluleImageView.contentMode = .ScaleAspectFill
                        }
                    }
                }
            }
            return cell
        }
    }
    
    /* Cablement du segue pour le détail des cocktails */
    
    // Exécute la cellule sélectionnée de la collectionView
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let currentObject = cocktails[indexPath.row]
        performSegueWithIdentifier("segueViewController", sender: currentObject)
    }
    
    
    // Dans la storyboard, preparation avec la navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
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
    }
    
    /* Fonctionnement de la Rechercher */
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
        // Ferme le clavier
        searchBar.resignFirstResponder()
        
        // Recharge les données de la table
        self.chargementDonneesRechercherCollectionView()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        // Ferme le clavier
        searchBar.resignFirstResponder()
        
        // Recharge les données de la table
        self.chargementDonneesRechercherCollectionView()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        searchBar.text = ""
        
        // Ferme le clavier
        searchBar.resignFirstResponder()
        
        // Recharge les données de la table
        self.chargementDonneesRechercherCollectionView()
    }
    
}










