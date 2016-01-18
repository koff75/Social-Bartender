//
//  ViewController.swift
//  Social Bartender
//
//  Created by nico on 06/11/2015.
//  Copyright © 2015 Nicolas Barthere. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4

class ViewController: UIViewController {

    @IBOutlet weak var adresseMailTextField: UITextField!
    @IBOutlet weak var motDePasseTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Supprime la Top Bar Navigation de la vue
        self.navigationController?.navigationBar.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sidentifierButtonTapped(sender: AnyObject) {
        let mailUtilisateur = self.adresseMailTextField.text
        let passUtilisateur = self.motDePasseTextField.text
        
        if((mailUtilisateur!.isEmpty || passUtilisateur!.isEmpty)){
            return
        }
        
        // Fermeture du clavier
        self.view.endEditing(true)
        
        // Affichage du popup de chargement lors de l'identification
        let chargement = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        chargement.labelText = "Identification"
        chargement.detailsLabelText = "Chargement en cours"
        
        let query = PFUser.query()
        query!.whereKey("email", equalTo: adresseMailTextField.text!)
        query!.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            
            // Fermeture de la popup de chargement
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            // Si l'utilisateur n'a pas vérifié son email
            if(PFUser.currentUser()?.objectForKey("emailVerified")?.boolValue == false) {
                CaptureErreurs.erreurParDefautString("Veuillez vérifier votre Email")
                return
            }

            if(error == nil){
                if objects!.count > 0 {
                    let object = objects![0] as! PFObject
                    let userName = object["username"] as! String
                    PFUser.logInWithUsernameInBackground(userName, password: passUtilisateur!, block: { (utilisateur: PFUser?, erreur: NSError?) -> Void in
                        print("Login avec le mail")
                        if(erreur != nil) {
                            CaptureErreurs.erreurParDefaut(erreur!)
                        }
                        // On charge le profil utilisateur
                        else {
                            let nomUtilisateur:String? = utilisateur?.username
                            // Permet de mémoriser même en quittant l'appli le nom de l'utilisateur
                            NSUserDefaults.standardUserDefaults().setObject(nomUtilisateur, forKey: "nom_utilisateur")
                            NSUserDefaults.standardUserDefaults().synchronize()
                            
                            // Navigation vers une page protégée quand l'utilisateur à bien rentré ses identifiants
                            /* (plus besoin) let mainStoryBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            var pagePrincipale:PagePrincipaleViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("PagePrincipaleViewController") as! PagePrincipaleViewController
                            var pagePrincipaleNav = UINavigationController(rootViewController: pagePrincipale)
                            var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            appDelegate.window?.rootViewController = pagePrincipaleNav */
                            var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            // On appelle la methode dans appDelegate qui va construire l'interface
                            appDelegate.creationInterfaceUtilisateur()
                        }
                    })
                } else {
                    PFUser.logInWithUsernameInBackground(mailUtilisateur!, password: passUtilisateur!, block: { (utilisateur    : PFUser?, erreur: NSError?) -> Void in
                        print("Login avec le nom complet")
                        if(erreur != nil) {
                            CaptureErreurs.erreurParDefaut(erreur!)
                        }
                        // On charge le profil utilisateur
                        else {
                            let nomUtilisateur:String? = utilisateur?.username
                            // Permet de mémoriser même en quittant l'appli le nom de l'utilisateur
                            NSUserDefaults.standardUserDefaults().setObject(nomUtilisateur, forKey: "nom_utilisateur")
                            NSUserDefaults.standardUserDefaults().synchronize()
                            
                            // Navigation vers une page protégée quand l'utilisateur à bien rentré ses identifiants
                            /* (plus besoin) let mainStoryBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            var pagePrincipale:PagePrincipaleViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("PagePrincipaleViewController") as! PagePrincipaleViewController
                            var pagePrincipaleNav = UINavigationController(rootViewController: pagePrincipale)
                            var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            appDelegate.window?.rootViewController = pagePrincipaleNav */
                            var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            // On appelle la methode dans appDelegate qui va construire l'interface
                            appDelegate.creationInterfaceUtilisateur()
                        }
                    })
                }
                
            }else{
                
                print("Error in retrieving \(error)")
            }
            
        }
        // Connexion à la base Parse et on retourne l'utilisateur (si existant) et son code d'erreur
        /* PFUser.logInWithUsernameInBackground(mailUtilisateur!, password: passUtilisateur!) { (utilisateur:PFUser?, erreur:NSError?) -> Void in

            // Fermeture de la popup de chargement
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            var messageUtilisateur = "Bienvenue"
            
            // Si l'utilisateur n'a pas vérifié son email
            if(PFUser.currentUser()?.objectForKey("emailVerified")?.boolValue == false) {
                messageUtilisateur = "Veuillez vérifier votre Email"
                // Popup alerte
                if #available(iOS 8.0, *) {
                    var alerte = UIAlertController(title: "Attention", message: messageUtilisateur, preferredStyle: UIAlertControllerStyle.Alert)
                    let okBouton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                    alerte.addAction(okBouton)
                    self.presentViewController(alerte, animated: true, completion: nil)
                } else {
                    // Fallback on earlier versions
                    let alerte = UIAlertView()
                    alerte.title = "Attention"
                    alerte.message = messageUtilisateur
                    alerte.addButtonWithTitle("Ok")
                    alerte.show()
                }
                return
            }
            // Si les champs sont bien rentrés
            if(erreur == nil){
                let nomUtilisateur:String? = utilisateur?.username
                // Permet de mémoriser même en quittant l'appli le nom de l'utilisateur
                NSUserDefaults.standardUserDefaults().setObject(nomUtilisateur, forKey: "nom_utilisateur")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                // Navigation vers une page protégée quand l'utilisateur à bien rentré ses identifiants
                /* (plus besoin) let mainStoryBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                var pagePrincipale:PagePrincipaleViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("PagePrincipaleViewController") as! PagePrincipaleViewController
                var pagePrincipaleNav = UINavigationController(rootViewController: pagePrincipale)
                var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.window?.rootViewController = pagePrincipaleNav */
                var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                // On appelle la methode dans appDelegate qui va construire l'interface
                appDelegate.creationInterfaceUtilisateur()
            } else{
                messageUtilisateur = erreur!.localizedDescription
                // Popup alerte
                if #available(iOS 8.0, *) {
                    var alerte = UIAlertController(title: "Attention", message: messageUtilisateur, preferredStyle: UIAlertControllerStyle.Alert)
                    let okBouton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                    alerte.addAction(okBouton)
                    self.presentViewController(alerte, animated: true, completion: nil)
                } else {
                    // Fallback on earlier versions	
                    let alerte = UIAlertView()
                    alerte.title = "Attention"
                    alerte.message = messageUtilisateur
                    alerte.addButtonWithTitle("Ok")
                    alerte.show()
                }
            }
        }*/
    }

    @IBAction func facebookButtonTapped(sender: AnyObject) {
        let permission = ["public_profile", "email"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permission) { (utilisateur:PFUser?, erreur:NSError?) -> Void in
            if(erreur != nil) {
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
            // Sinon on charge le profil Fb utilisateur
            self.chargerProfilFBUtilisateur()
        }
    }
    func chargerProfilFBUtilisateur() {
        // Affichage du popup de chargement lors de l'identification
        let chargement = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        chargement.labelText = "Identification"
        chargement.detailsLabelText = "Chargement en cours"
        
        // Lecture des paramètres reçus par FB
        var paramRecuFB = ["fields": "id, email, first_name, last_name, name"]
        
        // Requete vers moi
        let detailsUtilisateur = FBSDKGraphRequest(graphPath: "me", parameters: paramRecuFB)
        detailsUtilisateur.startWithCompletionHandler { (connexion, resultat, erreur:NSError!) -> Void in
            if(erreur != nil) {
                // Fermer le popup chargement
                chargement.hide(true)
                // Popup alerte
                let messageUtilisateur = erreur!.localizedDescription
                if #available(iOS 8.0, *) {
                    var alerte = UIAlertController(title: "Attention", message: messageUtilisateur, preferredStyle: UIAlertControllerStyle.Alert)
                    let okBouton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                    alerte.addAction(okBouton)
                    self.presentViewController(alerte, animated: true, completion: nil)
                    // Déconnexion Parse
                    PFUser.logOut()
                    return
                } else {
                    // Fallback on earlier versions
                    let alerte = UIAlertView()
                    alerte.title = "Attention"
                    alerte.message = messageUtilisateur
                    alerte.addButtonWithTitle("Ok")
                    alerte.show()
                    // Déconnexion Parse
                    PFUser.logOut()
                    return
                }
            }
            // Sinon, on extrait les champs de l'utilisateur
            let IDUtilisateur:String = resultat["id"] as! String
            let nomUtilisateur:String? = resultat["last_name"] as? String
            let prenomUtilisateur:String? = resultat["first_name"] as? String
            var mailUtilisateur:String? = resultat["email"] as? String
            let completUtilisateur:String = resultat["name"] as! String
            // Récupération de la photo de l'utilisateur
            var photoProfilUtilisateur = "https://graph.facebook.com/" + IDUtilisateur + "/picture?type=large"
            let photoProfilURL = NSURL(string: photoProfilUtilisateur)
            let photoProfilData = NSData(contentsOfURL: photoProfilURL!)
            if(photoProfilData != nil) {
                let photoProfilObjet = PFFile(data: photoProfilData!)
                PFUser.currentUser()?.setObject(photoProfilObjet!, forKey: "photoProfil_utilisateur")
            }
            PFUser.currentUser()?.setObject(prenomUtilisateur!, forKey: "prenom_utilisateur")
            PFUser.currentUser()?.setObject(nomUtilisateur!, forKey: "nom_utilisateur")
            // Vérification si le mail n'est pas nil, car il se peut que l'adresse mail ne soit pas renvoyée
            if let mailUtilisateur = mailUtilisateur {
                PFUser.currentUser()?.email = mailUtilisateur
                // Permet à l'utilisateur de se logger avec son mail
                PFUser.currentUser()?.username = completUtilisateur
            }
            // Sauvegarde dans Parse (background)
            PFUser.currentUser()?.saveInBackgroundWithBlock({ (ok:Bool, erreur:NSError?) -> Void in
                // S'il y a une erreur
                if(erreur != nil) {
                    // Popup alerte
                    let messageUtilisateur = erreur!.localizedDescription
                    if #available(iOS 8.0, *) {
                        var alerte = UIAlertController(title: "Attention", message: messageUtilisateur, preferredStyle: UIAlertControllerStyle.Alert)
                        let okBouton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                        alerte.addAction(okBouton)
                        self.presentViewController(alerte, animated: true, completion: nil)
                        // Déconnexion Parse
                        PFUser.logOut()
                        return
                    } else {
                        // Fallback on earlier versions
                        let alerte = UIAlertView()
                        alerte.title = "Attention"
                        alerte.message = messageUtilisateur
                        alerte.addButtonWithTitle("Ok")
                        alerte.show()
                        // Déconnexion Parse
                        PFUser.logOut()
                        return
                    }
                }
                // Si pas d'erreur
                if(ok) {
                    if (!IDUtilisateur.isEmpty) {
                        // On stocker ses infos en local
                        NSUserDefaults.standardUserDefaults().setObject(IDUtilisateur, forKey: "nom_utilisateur")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            // On construit l'interface utilisateur
                            appDelegate.creationInterfaceUtilisateur()
                        }
                    }
                }
            })
        }
    }
    
    @IBAction func retourButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /* Passage au textField suivant quand le bouton "Suivant" du clavier est appuyé
        Ajouter des tags via la storyboard avant
        CTRL drag du textField vers le bouton jaune, pour créer un Delegate
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let tagSuivant: NSInteger = textField.tag + 1;
        // Tente de trouver le nouveau Responder
        if let responderSuivant: UIResponder! = textField.superview!.viewWithTag(tagSuivant){
            responderSuivant.becomeFirstResponder()
        }
        else {
            // Si non trouvé, il ferme de clavier
            textField.resignFirstResponder()
        }
        // Si le bouton clavier est "Envoyer", on appelle la méthode "sidentifierButtonTapped"
        textField.addTarget(self, action: "sidentifierButtonTapped:", forControlEvents: .EditingDidEndOnExit)
        return true // We do not want UITextField to insert line-breaks.
    }
    
    
}