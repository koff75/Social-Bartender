//
//  ParseRequete.swift
//  Social Bartender
//
//  Created by nico on 01/12/2015.
//  Copyright © 2015 Nicolas Barthere. All rights reserved.
//

import UIKit
import Parse

class ParseRequete: NSObject {
    
    // Relation de suivi de contenu
    static let ParseSuivreClasse       = "Suivre"
    static let ParseSuivreduUser       = "duUser"
    static let ParseSuivreVersUser     = "versUser"
    
    // Relation j'aime
    static let ParseJaimeClasse          = "Likes"
    static let ParseJaimeVersPublication = "versCocktail_perso"
    static let ParseJaimeduUser          = "duUser"
    
    // Relation sur les publications
    static let ParsePublicationUser             = "user"
    static let ParsePublicationDateCreation     = "createdAt"
    
    // Relation sur le contenu suivit
    static let ParseContenuSuivitClasse           = "Contenu_suivit"
    static let ParseContenuSuivitduUser           = "duUser"
    static let ParseContenuSuivitVersPublication  = "versCocktail_perso"
    
    // Relation entre utilisateurs
    static let ParseNomUser      = "prenom_utilisateur"
    
    
    // MARK: Requêtes Likes
    
    // Mettre static pour tous les helpers. Evite alors de faire une instance de ParseRequete
    // completionBlock est un callback appelé quand la requete est terminée
    static func requetesTimelineUtilisateurCourant(rang: Range<Int>, completionBlock: PFQueryArrayResultBlock) {
        // Lister toutes les personnes que l'utilisateur suit
        let requeteSuit = PFQuery(className: ParseSuivreClasse)
        requeteSuit.whereKey(ParseJaimeduUser, equalTo: PFUser.currentUser()!)
        
        // 2.Dans Publication - col : user.
        // Cherche toutes les publications publiées par ses amis (followers)
        let publicationUtilisateursSuivis = Publication.query()
        publicationUtilisateursSuivis!.whereKey(ParsePublicationUser, matchesKey: ParseSuivreVersUser, inQuery: requeteSuit)
        
        // 3.Récupérer tous les publications de l'utilisateur courrant
        let publicationUtilisateur = Publication.query()
        publicationUtilisateur!.whereKey(ParsePublicationUser, equalTo: PFUser.currentUser()!)
        
        // Retourne les publications entre 2 et 3
        let requete = PFQuery.orQueryWithSubqueries([publicationUtilisateursSuivis!, publicationUtilisateur!])
        // Association de la table Publication et du pointeur User*
        requete.includeKey(ParsePublicationUser)
        // Les publications s'afficheront chronologiquement
        requete.orderByDescending(ParsePublicationDateCreation)
        
        // Le rang définie la proportion de la timeLine à charger
        // Combien d'éléments peuvent être skip
        requete.skip = rang.startIndex
        // limit : Combien d'éléments à charger
        requete.limit = rang.endIndex - rang.startIndex
        
        //requete.findObjectsInBackgroundWithBlock(completionBlock)
        requete.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    
    static func jaimeLaPublication(user: PFUser, publication: Publication) {
        let objetJaime = PFObject(className: ParseJaimeClasse)
        objetJaime[ParseJaimeduUser] = user
        objetJaime[ParseJaimeVersPublication] = publication
        
        objetJaime.saveInBackgroundWithBlock(CaptureErreurs.erreurCallback)
    }
    
    static func jaimePlusPublication(user: PFUser, publication: Publication) {
        let requete = PFQuery(className: ParseJaimeClasse)
        requete.whereKey(ParseJaimeduUser, equalTo: user)
        requete.whereKey(ParseJaimeVersPublication, equalTo: publication)
        
        requete.findObjectsInBackgroundWithBlock { (resultats: [PFObject]?, erreur: NSError?) -> Void in
            if let erreur = erreur {
                CaptureErreurs.erreurParDefaut(erreur)
            }
            if let resultats = resultats as [PFObject]! {
                // Si le user à des pb de réseaux, il peut avoir plusieurs likes sur la photo, donc, on les passe tous au cas ou
                for jaimes in resultats {
                    jaimes.deleteInBackgroundWithBlock(CaptureErreurs.erreurCallback)
                }
            }
        }
    }
    
    // Rechercher tous les likes pour une seule publication
    static func JaimesDunePublication(publication: Publication, completionBlock: PFQueryArrayResultBlock) {
        let requete = PFQuery(className: ParseJaimeClasse)
        requete.whereKey(ParseJaimeVersPublication, equalTo: publication)
        // Permet de récupérer les nom des users qui aiment
        requete.includeKey(ParseJaimeduUser)
        
        requete.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    // MARK: Suivre Amis
    
    /**
    Vérifie les amis que suit l'utilisateur
    
    :param: utilisateur L'utilisateur dont on veux récuperer les publications
    :param: completionBlock La completion block qui est appellée quand la requête est terminée
    */
    static func recupFollowers(utilisateur: PFUser, completionBlock: PFQueryArrayResultBlock) {
        let requete = PFQuery(className: ParseSuivreClasse)
        
        requete.whereKey(ParseSuivreduUser, equalTo:utilisateur)
        requete.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    /**
     Etablie la relation entre deux utilisateurs
     
     :param: utilisateur L'utilisateur qui follow
     :param: versUtilisateur  L'utilisateur qui est suivit
     */
    static func ajouterFollower(utilisateur: PFUser, versUtilisateur: PFUser) {
        let followObjet = PFObject(className: ParseSuivreClasse)
        followObjet.setObject(utilisateur, forKey: ParseSuivreduUser)
        followObjet.setObject(versUtilisateur, forKey: ParseSuivreVersUser)
        
        followObjet.saveInBackgroundWithBlock(CaptureErreurs.erreurCallback)
    }
    
    /**
     Supprime une relation entre deux utilisateurs
     
     :param: utilisateur L'utilisateur qui follow
     :param: versUtilisateur  L'utilisateur qui est suivit
     */
    static func supprimerFollower(utilisateur: PFUser, versUtilisateur: PFUser) {
        let requete = PFQuery(className: ParseSuivreClasse)
        requete.whereKey(ParseSuivreduUser, equalTo:utilisateur)
        requete.whereKey(ParseSuivreVersUser, equalTo: versUtilisateur)
        
        requete.findObjectsInBackgroundWithBlock {
            (results: [PFObject]?, error: NSError?) -> Void in
            // let results = results as? [PFObject] ?? []
            let results = results ?? []
            
            for follow in results {
                follow.deleteInBackgroundWithBlock(CaptureErreurs.erreurCallback)
            }
        }
    }
    
    // MARK: Utilisateur
    
    // Méthodes qui renvoie des PFQuery. Permet de garder la référence de la requete sur ce qu'il est 
    // en train de se passer. Pour éviter les pb sur les users qui tappent vite dans la barre de recherche
    // A chaque fois, il va annuler la requete en cours avant de démarrer la nouvelle.
    
    /**
    Vérifie tous les utilisateurs, sauf celui qui est identifié
    Limite le taux d'utilisateur retourné à 20
    >
    :param: completionBlock La completion block qui est appellée quand la requête est terminée
    >
    :returns: La requête générée PFQuery
    */
    static func tousUtilisateurs(completionBlock: PFQueryArrayResultBlock) -> PFQuery {
        let requete = PFUser.query()!
        // exclude the current user
        requete.whereKey(ParseRequete.ParseNomUser,
            notEqualTo: PFUser.currentUser()!.username!)
        requete.orderByAscending(ParseRequete.ParseNomUser)
        requete.limit = 20
        
        requete.findObjectsInBackgroundWithBlock(completionBlock)
        
        return requete
    }
    
    /**
     Vérifie les utilisateurs dont leurs noms match avec la recherche
     >
     :param: rechercheTexte Le texte saisi par l'utilisateur dans le champ rechercher
     :param: completionBlock La completion block qui est appellée quand la requête est terminée
     >
     :returns: La requête générée PFQuery
     */
    static func chercherUtilisateur(rechercheTexte: String, completionBlock: PFQueryArrayResultBlock)
        -> PFQuery {
            /*
            NOTE: We are using a Regex to allow for a case insensitive compare of usernames.
            Regex can be slow on large datasets. For large amount of data it's better to store
            lowercased username in a separate column and perform a regular string compare.
            */
            let requete = PFUser.query()!.whereKey(ParseRequete.ParseNomUser,
                matchesRegex: rechercheTexte, modifiers: "i")
            
            requete.whereKey(ParseRequete.ParseNomUser,
                notEqualTo: PFUser.currentUser()!.username!)
            
            requete.orderByAscending(ParseRequete.ParseNomUser)
            requete.limit = 20
            
            requete.findObjectsInBackgroundWithBlock(completionBlock)
            
            return requete
    }
}


// Dit à Parse que deux objects parse sont équivalents si ils ont le même id
extension PFObject {
    public override func isEqual(object: AnyObject?) -> Bool {
        if (object as? PFObject)?.objectId == self.objectId {
            return true
        } else {
            return super.isEqual(object)
        }
    }
}