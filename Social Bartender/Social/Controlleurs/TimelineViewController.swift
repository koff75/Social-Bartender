//
//  TimelineViewController.swift
//  Social Bartender
//
//  Created by nico on 28/11/2015.
//  Copyright © 2015 Nicolas Barthere. All rights reserved.
//

import UIKit
import ConvenienceKit
import Parse

class TimelineViewController: UIViewController, TimelineComponentTarget {
    
    var timelineComponent: TimelineComponent<Publication, TimelineViewController>!
    
    @IBOutlet weak var tableView: UITableView!
    
    // Combien de publications doivent être chargées initiallement
    let defaultRange = 0...4
    // Pareil mais se déclenche quand le user est en bas de la page
    let additionalRangeSize = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timelineComponent = TimelineComponent(target: self)
        
        // Chaque onglet prend le delegate de UItabbar
        // Le delegate de UITabBarController est TimelineViewController
        self.tabBarController?.delegate = self
        //self.automaticallyAdjustsScrollViewInsets = false
        // Permet d'enlever l'espace blanc vide, navigationController
        self.navigationController?.navigationBarHidden = true
        
        // Je monte de 20px qui correspondait à un blanc de la status bar (tweak)
        self.navigationController?.navigationBarHidden = true
        self.navigationController!.navigationBar.frame = CGRectOffset(self.navigationController!.navigationBar.frame, 0.0, -20.0);
        //UIApplication.sharedApplication().statusBarStyle = .BlackOpaque

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        timelineComponent.loadInitialIfRequired()
    }
    
    func loadInRange(range: Range<Int>, completionBlock: ([Publication]?) -> Void) {
        // Demarrage de la connexion réseau   Probleme sur PFOjbect
        ParseRequete.requetesTimelineUtilisateurCourant(range) { (resultat: [PFObject]?, erreur: NSError?) -> Void in
            // Réponse de type [AnyObject]?, donc cast en type [Post], si retour nil, nous mettons : [] (=vide)
            let publications = resultat as? [Publication] ?? []
            // Un fois stocké les messages, il y a mise à jour de la tableView
            completionBlock(publications)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    // Dans la storyboard, preparation avec la navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
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

// MARK: Gestion de la Tab Bar

// Quand l'onglet photo est sélectionné => false
extension TimelineViewController: UITabBarControllerDelegate {
    
    /*func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if (viewController is PhotoViewController) {
            //prendrePhoto()
            // Ne prendra pas le focus sur le bouton, donc, relachera dessuite
            print("False")
            return false
        } else {
            print("True")
            return true
        }
    }*/
}

extension TimelineViewController: UITableViewDataSource {
    // On n'affiche plus des lignes mais des sections
    // Taille de la longueur du bandeau header
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return timelineComponent.content.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let celluleHeader = tableView.dequeueReusableCellWithIdentifier("MaCelluleHeader") as! PublicationHeaderTableViewCell
        
        let publication = self.timelineComponent.content[section]
        celluleHeader.publication = publication
        
        return celluleHeader
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellule = tableView.dequeueReusableCellWithIdentifier("MaCellule") as! PublicationTableViewCell
        let publication = timelineComponent.content[indexPath.section]
        // Telecharger l'image avec que la cellule soit visible
        publication.telechargerImage()
        publication.capturerJaime()
        cellule.publication = publication
        return cellule
    }
    
}

// On appelle timelineComponent et on lui informe qu'une cellule est apparut
extension TimelineViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        timelineComponent.targetWillDisplayEntry(indexPath.section)
    }

    /* Cablement du segue pour le détail des cocktails */

    // Exécute la cellule sélectionnée de la collectionView
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let currentObject = timelineComponent.content[indexPath.section]
        performSegueWithIdentifier("segueViewController3", sender: currentObject)
    }
}