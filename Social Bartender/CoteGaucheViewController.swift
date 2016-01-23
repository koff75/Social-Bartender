//
//  CoteGaucheViewController.swift
//  Social Bartender
//
//  Created by nico on 08/11/2015.
//  Copyright © 2015 Nicolas Barthere. All rights reserved.
//

import UIKit
import Parse

class CoteGaucheViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Liste des noms du menu
    var listeMenu:[String] = ["Selection", "Recherche", "Timeline", "Classement", "Configuration","Déconnexion"]
    
    // Variables UI
    @IBOutlet weak var photoUtilisateurImageView: UIImageView!
    @IBOutlet weak var nomUtilisateurLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Demande à Parse de nous retourner l'utilisateur courant avec downcast
        let prenom_utilisateur = PFUser.currentUser()?.objectForKey("prenom_utilisateur") as! String
        let nom_utilisateur = PFUser.currentUser()?.objectForKey("nom_utilisateur") as! String
        nomUtilisateurLabel.text = prenom_utilisateur + " " + nom_utilisateur
        if(PFUser.currentUser()?.objectForKey("photoProfil_utilisateur") != nil){
            let photoProfil_utilisateur_objet = PFUser.currentUser()?.objectForKey("photoProfil_utilisateur") as! PFFile
            photoProfil_utilisateur_objet.getDataInBackgroundWithBlock { (image:NSData?, erreur:NSError?) -> Void in
                if(image != nil) {
                    self.photoUtilisateurImageView.image = UIImage(data: image!)
                    // Rogner l'image
                    self.photoUtilisateurImageView.contentMode = .ScaleAspectFill
                    // Permet de créer un cercle atour de la photoProfil
                    self.photoUtilisateurImageView.layer.cornerRadius = self.photoUtilisateurImageView.frame.size.width / 2;
                    self.photoUtilisateurImageView.layer.borderWidth = 1.0
                    self.photoUtilisateurImageView.clipsToBounds = true
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Retourne le nombre d'élément dans la tableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listeMenu.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let maCellule = tableView.dequeueReusableCellWithIdentifier("MaCellule", forIndexPath: indexPath) as! CustomTableViewCell
        // On écris dans le label le champ du tableau listeMenu
        maCellule.menuItemLabel.text = listeMenu[indexPath.row]
        return maCellule
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch(indexPath.row) {
        case 0:
            // Ouverture Selection Cocktail
            let pagePrincipaleViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RechercherCocktailViewController2") as! RechercherCocktailViewController
            let pagePrincipaleNav = UINavigationController(rootViewController:pagePrincipaleViewController)
            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.contenuDrawer!.centerViewController = pagePrincipaleNav
            appDelegate.contenuDrawer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)

            break

        case 1:
            // Ouverture Rechercher un Cocktail
            let rechercherCocktailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RechercherCocktailViewController") as! RechercherCocktailViewController
            let rechercherCocktailViewControllerNav = UINavigationController(rootViewController:rechercherCocktailViewController)
            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.contenuDrawer!.centerViewController = rechercherCocktailViewControllerNav
            appDelegate.contenuDrawer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
            break
        case 2:
            // Timeline
            let socialTabBarController = self.storyboard?.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
            let socialTabBarControllerNav = UINavigationController(rootViewController:socialTabBarController)
            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.contenuDrawer!.centerViewController = socialTabBarControllerNav
            appDelegate.contenuDrawer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
            break
        case 3:
            // Classement
            let classementTabBarController = self.storyboard?.instantiateViewControllerWithIdentifier("ClassementViewController") as! ClassementViewController
            let classementTabBarControllerNav = UINavigationController(rootViewController:classementTabBarController)
            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.contenuDrawer!.centerViewController = classementTabBarControllerNav
            appDelegate.contenuDrawer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
            break
        /*case 3:
            // Créer un coktail
            var creerCocktailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CreerCocktailViewController") as! CreerCocktailViewController
            var creerCocktailViewControllerNav = UINavigationController(rootViewController:creerCocktailViewController)
            var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.contenuDrawer!.centerViewController = creerCocktailViewControllerNav
            appDelegate.contenuDrawer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
            break*/
        case 4:
            // Configuration de récipients de la machine
            let configurationViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ConfigurationViewController") as! ConfigurationViewController
            let configurationViewControllerNav = UINavigationController(rootViewController:configurationViewController)
            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.contenuDrawer!.centerViewController = configurationViewControllerNav
            appDelegate.contenuDrawer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
            break
        case 5:
            // Deconnexion
            // Affichage du popup de chargement lors de la déconnexion
            let chargement = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            chargement.labelText = "Déconnexion"
            chargement.detailsLabelText = "Chargement en cours"
            // Supprime la clé de l'utilisateur stockée sur le téléphone
            NSUserDefaults.standardUserDefaults().removeObjectForKey("nom_utilisateur")
            NSUserDefaults.standardUserDefaults().synchronize()
            // Déconnexion sur Parse
            PFUser.logOutInBackgroundWithBlock { (erreur:NSError?) -> Void in
                // Revenir sur la page d'identification
                let mainStoryBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let accueilViewController:AccueilViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("AccueilViewController") as! AccueilViewController
                let accueilViewControllerNav = UINavigationController(rootViewController: accueilViewController)
                let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.window?.rootViewController = accueilViewControllerNav
            }
            break
        default:
            print(listeMenu[indexPath.row]);
            print(" selectionné")
        }
    }

}
