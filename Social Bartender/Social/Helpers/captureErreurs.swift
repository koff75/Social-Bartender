//
//  captureErreurs.swift
//  Social Bartender
//
//  Created by nico on 22/12/2015.
//  Copyright © 2015 Nicolas Barthere. All rights reserved.
//

import Foundation
import ConvenienceKit

/**
 Struture qui fournie les captures des erreurs.
 */
struct CaptureErreurs {
    
    static let ErrorTitle           = "Erreur"
    static let ErrorOKButtonTitle   = "Ok"
    static let ErrorDefaultMessage  = "Quelques chose de spécial s'est passé, désolé !"
    
    /**
     Erreur par défaut, avec capture d'un NSError, avec Alert View en fenêtre modale
     */
    static func erreurParDefaut(error: NSError) {
        let alerte = UIAlertController(title: ErrorTitle, message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
        alerte.addAction(UIAlertAction(title: ErrorOKButtonTitle, style: UIAlertActionStyle.Default, handler: nil))
        
        let fenetre = UIApplication.sharedApplication().windows[0]
        fenetre.rootViewController?.presentViewControllerFromTopViewController(alerte, animated: true, completion: nil)
    }
    /**
     Erreur par défaut, avec capture d'un String, avec Alert View en fenêtre modale
     */
    static func erreurParDefautString(message: String) {
        let alerte = UIAlertController(title: ErrorTitle, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alerte.addAction(UIAlertAction(title: ErrorOKButtonTitle, style: UIAlertActionStyle.Default, handler: nil))
        
        let fenetre = UIApplication.sharedApplication().windows[0]
        fenetre.rootViewController?.presentViewControllerFromTopViewController(alerte, animated: true, completion: nil)
    }
    
    /**
     A PFBooleanResult callback block that only handles error cases. You can pass this to completion blocks of Parse Requests
     */
    static func erreurCallback(success: Bool, erreur: NSError?) -> Void {
        if let erreur = erreur {
            CaptureErreurs.erreurParDefaut(erreur)
        }
    }
    
    
    /**
     Information par défaut
    */
     /**
     Erreur par défaut, avec capture d'un NSError, avec Alert View en fenêtre modale
     */
    static func informationParDefautString(message: String) {
        let alerte = UIAlertController(title: "Information", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alerte.addAction(UIAlertAction(title: ErrorOKButtonTitle, style: UIAlertActionStyle.Default, handler: nil))
        
        let fenetre = UIApplication.sharedApplication().windows[0]
        fenetre.rootViewController?.presentViewControllerFromTopViewController(alerte, animated: true, completion: nil)
    }
    
}