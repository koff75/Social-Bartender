//
//  MotDePasseOublieViewController.swift
//  Social Bartender
//
//  Created by nico on 08/11/2015.
//  Copyright © 2015 Nicolas Barthere. All rights reserved.
//

import UIKit
import Parse

class MotDePasseOublieViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func envoyerButtonTapped(sender: AnyObject) {
        let email = self.emailTextField.text
        if(email!.isEmpty) {
            // Afficher un warning
            let messageUtilisateur:String = "Merci de saisir votre adresse mail"
            afficherMessage(messageUtilisateur)
            return
        }
        PFUser.requestPasswordResetForEmailInBackground(email!) { (envoieOk:Bool, erreur:NSError?) -> Void in
            if(erreur != nil) {
                // Afficher un message d'erreur
                let messageUtilisateur:String = erreur!.localizedDescription
                self.afficherMessage(messageUtilisateur)
            } else {
                // Affiche un message d'envoie
                let messageUtilisateur:String = "Un email à été envoyé vers \(email)"
                self.afficherMessage(messageUtilisateur)
            }
        }
    }
    
    func afficherMessage(messageUtilisateur:String) {
        if #available(iOS 8.0, *) {
            var alerte = UIAlertController(title: "Attention", message: messageUtilisateur, preferredStyle: UIAlertControllerStyle.Alert)
            let actionOk = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) {
                action in
                // Quand on clique sur Ok, la fenetre revient sur la page identification
                self.dismissViewControllerAnimated(true, completion: nil)
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
        }
        
    }
    
    @IBAction func annulerButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
