//
//  InscriptionViewController.swift
//  Social Bartender
//
//  Created by nico on 06/11/2015.
//  Copyright © 2015 Nicolas Barthere. All rights reserved.
//

import UIKit
import Parse
import Bolts

class InscriptionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Declarations des variables du l'UI
    @IBOutlet weak var photoProfil: UIImageView!
    @IBOutlet weak var adresseMail: UITextField!
    @IBOutlet weak var motDePasse: UITextField!
    @IBOutlet weak var motDePasseResaisir: UITextField!
    @IBOutlet weak var prenom: UITextField!
    @IBOutlet weak var nom: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    /* Permet de faire glisser le clavier en bas d'un textField*/
    // Appelée à chaque fois que le clavier monte
    func textFieldDidBeginEditing(textField: UITextField) {
        if(textField == adresseMail || textField == motDePasse || textField == motDePasseResaisir) {
            animateViewMoving(true, moveValue: 105) }
    }
    // Appelée à chaque fois que le clavier descend
    func textFieldDidEndEditing(textField: UITextField) {
        if(textField != prenom && textField != motDePasseResaisir) {
            animateViewMoving(false, moveValue: 50) }
        if(textField == nom) { animateViewMoving(false, moveValue: 165) }

    }
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        var movementDuration:NSTimeInterval = 0.3
        var movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }
    
    
    
    // Surcharge les layouts, a verif si effet elastic sur le scroll
    override func viewDidLayoutSubviews() {
        self.edgesForExtendedLayout = UIRectEdge()
        // Modifie le TextField avec une barre horizontale : adresseMail
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.lightGrayColor().CGColor
        border.frame = CGRect(x: 0, y: adresseMail.frame.size.height - width, width:  adresseMail.frame.size.width, height: adresseMail.frame.size.height)
        border.borderWidth = width
        adresseMail.layer.addSublayer(border)
        adresseMail.layer.masksToBounds = true
        // Modifie le TextField avec une barre horizontale : motDePasse
        let border1 = CALayer()
        let width1 = CGFloat(1.0)
        border1.borderColor = UIColor.lightGrayColor().CGColor
        border1.frame = CGRect(x: 0, y: motDePasse.frame.size.height - width1, width:  motDePasse.frame.size.width, height: motDePasse.frame.size.height)
        border1.borderWidth = width1
        motDePasse.layer.addSublayer(border1)
        motDePasse.layer.masksToBounds = true
        // Modifie le TextField avec une barre horizontale : motDePasseResaisir
        let border2 = CALayer()
        let width2 = CGFloat(1.0)
        border2.borderColor = UIColor.lightGrayColor().CGColor
        border2.frame = CGRect(x: 0, y: motDePasseResaisir.frame.size.height - width2, width:  motDePasseResaisir.frame.size.width, height: motDePasseResaisir.frame.size.height)
        border2.borderWidth = width2
        motDePasseResaisir.layer.addSublayer(border2)
        motDePasseResaisir.layer.masksToBounds = true
        // Modifie le TextField avec une barre horizontale : prenom
        let border3 = CALayer()
        let width3 = CGFloat(1.0)
        border3.borderColor = UIColor.lightGrayColor().CGColor
        border3.frame = CGRect(x: 0, y: prenom.frame.size.height - width3, width:  prenom.frame.size.width, height: prenom.frame.size.height)
        border3.borderWidth = width3
        prenom.layer.addSublayer(border3)
        prenom.layer.masksToBounds = true
        // Modifie le TextField avec une barre horizontale : nom
        let border4 = CALayer()
        let width4 = CGFloat(1.0)
        border4.borderColor = UIColor.lightGrayColor().CGColor
        border4.frame = CGRect(x: 0, y: nom.frame.size.height - width4, width:  nom.frame.size.width, height: nom.frame.size.height)
        border4.borderWidth = width4
        nom.layer.addSublayer(border4)
        nom.layer.masksToBounds = true
    }


    /* Passage au textField suivant quand le bouton "Suivant" du clavier est appuyé
    Ajouter des tags via la storyboard avant
    CTRL drag du textField vers le bouton jaune, pour créer un Delegate
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        var tagSuivant: NSInteger = textField.tag + 1;
        // Permet d'éviter un bug si l'utilisateur change de champ
        if(textField == adresseMail) { tagSuivant = 1 }
        // Tente de trouver le nouveau Responder
        if let responderSuivant: UIResponder! = textField.superview!.viewWithTag(tagSuivant){
            responderSuivant.becomeFirstResponder()
        }
        else {
            // Si non trouvé, il ferme de clavier
            textField.resignFirstResponder()
        }
        // Si le bouton clavier est "Envoyer", on appelle la méthode "boutonInscription"
        textField.addTarget(self, action: "boutonInscription:", forControlEvents: .EditingDidEndOnExit)
        return false // We do not want UITextField to insert line-breaks.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func ajouterPhotoProfil(sender: AnyObject) {
        var monPickerController = UIImagePickerController()
        monPickerController.delegate = self
        monPickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        // Dérouler l'animation
        self.presentViewController(monPickerController, animated: true, completion: nil)
    }
    
    // Fonction collée depuis UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // Info contient les informations a propose de l'image
        photoProfil.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        // Rogner l'image
        photoProfil.contentMode = .ScaleAspectFill
        // Enlever l'animation pour sélectionner la photo
        self.dismissViewControllerAnimated(true, completion: nil)
        
        // Permet de créer un cercle atour de la photoProfil
        photoProfil.layer.cornerRadius = photoProfil.frame.size.width / 2;
        self.photoProfil.layer.borderWidth = 1.0
        self.photoProfil.clipsToBounds = true

        
    }
    
    @IBAction func boutonAnnuler(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func boutonInscription(sender: AnyObject) {
        // Permet d'enlever le clavier quand le bouton est clické
        self.view.endEditing(true)
        
        let mailUtilisateur = adresseMail.text?.lowercaseString
        let passeUtilisateur = motDePasse.text
        let passeRepUtilisateur = motDePasseResaisir.text
        let prenomUtilisateur = prenom.text
        let nomUtilisateur = nom.text
        
        // Vérification si champ vide
        if(mailUtilisateur!.isEmpty || passeRepUtilisateur!.isEmpty || passeRepUtilisateur!.isEmpty || prenomUtilisateur!.isEmpty || nomUtilisateur!.isEmpty) {
            // Corp de l'arlerte
            if #available(iOS 8.0, *) {
                var alerte = UIAlertController(title: "Attention", message: "Champ vide !", preferredStyle: UIAlertControllerStyle.Alert)
                // Boutons de l'alerte
                let actionOk = UIAlertAction(title: "Je corrige", style: UIAlertActionStyle.Default, handler: nil)
                alerte.addAction(actionOk)
                // Affichage de l'alerte en fenetre modale
                presentViewController(alerte, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
                let alerte = UIAlertView()
                alerte.title = "Attention"
                alerte.message = "Champ vide !"
                alerte.addButtonWithTitle("Ok")
                alerte.show()
            }
            return
        }
        
        // Vérification si les mots de passe correspondent
        if(passeUtilisateur != passeRepUtilisateur) {
            if #available(iOS 8.0, *) {
                var alerte = UIAlertController(title: "Attention", message: "Mauvaise saisie du mot de passe", preferredStyle: UIAlertControllerStyle.Alert)
                let actionOk = UIAlertAction(title: "Je corrige", style: UIAlertActionStyle.Default, handler: nil)
                alerte.addAction(actionOk)
                presentViewController(alerte, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
                let alerte = UIAlertView()
                alerte.title = "Attention"
                alerte.message = "Mauvaise saisie du mot de passe"
                alerte.addButtonWithTitle("Je corrige")
                alerte.show()
            }

            return
        }
        
        // PF Parse Framework
        let nomComplet = prenomUtilisateur! + " " + nomUtilisateur!
        let utilisateur:PFUser = PFUser()
        utilisateur.email = mailUtilisateur
        utilisateur.username = nomComplet
        utilisateur.password = passeUtilisateur
        utilisateur.setObject(prenomUtilisateur!, forKey: "prenom_utilisateur")
        utilisateur.setObject(nomUtilisateur!, forKey: "nom_utilisateur")
        
        // Retourne la donnee pour une image jpeg
        if(photoProfil.image != nil){
            let photoProfilUtilisateur = UIImageJPEGRepresentation(photoProfil.image!, 0.5)
            // Verification si la photo est selectionnee
            if(photoProfilUtilisateur != nil){
                let photoProfilFichier = PFFile(data: photoProfilUtilisateur!)
                utilisateur.setObject(photoProfilFichier!, forKey: "photoProfil_utilisateur")
            }
        }
        // Affichage du popup de chargement lors de l'identification
        let chargement = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        chargement.labelText = "Inscription"
        chargement.detailsLabelText = "Chargement en cours"
        
        // Enregistrement de l'utilisateur dans la base de donnée Parse
        utilisateur.signUpInBackgroundWithBlock { (connecte:Bool, erreur:NSError?) -> Void in
            // Disparition de la popup chargement
            chargement.hide(true)
            var messageUtilisateur = "Inscription Enregistrée. Veuillez vérifier votre Email."
            if(!connecte){
                messageUtilisateur = "Inscription échouée. Merci d'esssayer plus tard."
                messageUtilisateur = erreur!.localizedDescription
            }
            if #available(iOS 8.0, *) {
                var alerte = UIAlertController(title: "Attention", message: messageUtilisateur, preferredStyle: UIAlertControllerStyle.Alert)
                let actionOk = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default){ action in
                    // Si l'utilisateur est s'est bien enregistré, on ferme le panneau InscriptionViewController
                    if(connecte){
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
                alerte.addAction(actionOk)
                self.presentViewController(alerte, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
                let alerte = UIAlertView()
                alerte.title = "Attention"
                alerte.message = messageUtilisateur
                alerte.addButtonWithTitle("Ok")
                alerte.show()
                if(connecte){
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }

        }

        
    }
    
    

}
