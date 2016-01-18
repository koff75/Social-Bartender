//
//  Publication.swift
//  Social Bartender
//
//  Created by nico on 30/11/2015.
//  Copyright © 2015 Nicolas Barthere. All rights reserved.
//

import UIKit
import Parse
import Foundation
import Bond
import ConvenienceKit


// Hériter du PFObject et utiliser le protocole Subclassing
class Publication: PFObject {
    
    /* NSCacheSwift va sotcker les valeurs des clés. Et quand, l'app reçoit un warning de la
    mémoire, il va vider automatiquement NSCacheSwift. Ce qui évite l'app d'être arrêtée par
    l'OS.
    Dès qu'une image est téléchargée et stockée dans le cache, on utilise le nom du PFFile comme
    clé pour le cache. On vérifie s'il est déjà téléchargé, si oui, on sort l'image du disque.
    */
    static var cacheImage: NSCacheSwift<String, UIImage>!
    
    // Attention, ces variables correspondent au nom des colonnes dans Parse
    @NSManaged var photo_cocktail: PFFile?
    @NSManaged var user: PFUser?
    @NSManaged var nom_cocktail: PFObject?

    var traitementEnvoiePhoto: UIBackgroundTaskIdentifier?

    // Permet de faire du bindings (bond), et permet de voir les changements de la variable
    var image: Observable<UIImage?> = Observable(nil)
    var jaimes: Observable<[PFUser]?> = Observable(nil)

    
    
    override init() {
        super.init()
    }
    
    
    // MARK: Téléchargement des J'aimes
    func capturerJaime() {
        // 1
        if (jaimes.value != nil) {
            return
        }
        
        // Récupérer les likes de la publication courante
        ParseRequete.JaimesDunePublication(self, completionBlock:  { (var jaimes: [PFObject]?,erreur: NSError?) -> Void in
            // Prend une closure et retourne un tableau
            // Supprime tous les likes des utilisateurs qui n'existent plus dans l'application
            jaimes = jaimes?.filter { like in like[ParseRequete.ParseJaimeduUser] != nil }
            
            // Closure pour chaque élément du tableau qui retourne un tableau
            // Map ne va pas supprimer les objets mais les remplacer
            // On remplace le tableau de like par celui des utilisateurs qui sont associés avec ces likes
            // Donc on démarre avec un tableau de like, et on obtient un tableau d'utilisateur
            self.jaimes.value = jaimes?.map { jaime in
                let jaime = jaime as! PFObject
                let duUser = jaime[ParseRequete.ParseJaimeduUser] as! PFUser
                
                return duUser
            }
        })
    }
    
    // MARK: Like Rouge ou like Gris
    func siUtilisateurAimePublication(utilisateur: PFUser) -> Bool {
        if let jaimes = jaimes.value {
            // Retourne true si l'object est dans le tableau
            return jaimes.contains(utilisateur)
        } else {
            return false
        }
    }
    
    // MARK: Ajouter/Enlever un jaime
    func attacherJaimePublication(utilisateur: PFUser) {
        if(siUtilisateurAimePublication(utilisateur)) {
            // Si la photo est aimée, enlever le jaime maintenant
            jaimes.value = jaimes.value?.filter { $0 != utilisateur }
            ParseRequete.jaimePlusPublication(utilisateur, publication: self)
        } else {
            // Si la photo n'est pas aimée encore, ajouter le jaime maintenant
            jaimes.value?.append(utilisateur)
            ParseRequete.jaimeLaPublication(utilisateur, publication: self)
        }
    }

    /* Requêtes Pour le Créer Un Cocktail */
    // MARK: Requêtes Créer Cocktail
    func envoyerPublication(texte: [String], colonne: [String]) {
        // Popup de chargement
        let chargement = MBProgressHUD.showHUDAddedTo(UIApplication.sharedApplication().windows.last, animated: true)
        chargement.labelText = "Création du Cocktail"
        chargement.detailsLabelText = "Envoie en cours"
        // Lance une fois que la tache background à terminée
        dispatch_async(dispatch_get_main_queue()) {
            // Ferme la popup de chargement
            
        // A Supprimer cette vérif :
        if let image = self.image.value {
            // Envoie l'image même si l'utilisateur Quitte l'application
            // Donc création d'une tache de fond, et la closure se lance quand le temps écoulé est Trop long
            self.traitementEnvoiePhoto = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.traitementEnvoiePhoto!)
            })
            
            let donneeImage = UIImageJPEGRepresentation(image, 0.8)!
            let fichierImage = PFFile(data: donneeImage)
            /* // Envoie de l'image sur Parse
            fichierImage?.saveInBackgroundWithBlock({ (ok: Bool, erreur: NSError?) -> Void in
                // Coupe quand c'est terminé
                UIApplication.sharedApplication().endBackgroundTask(self.traitementEnvoiePhoto!)
            })
            
            // Remplissage des variables avec l'utilisateur qui l'envoie et sa photo de cocktail
            user = PFUser.currentUser()
            self.photo_cocktail = fichierImage
            // Enregistrer la publication
            saveInBackgroundWithBlock(nil) */
            
            // DEBUT MODIF
            // Ajoutera le nom + origine + description + photo
            let objet = PFObject(className: "Cocktails_perso")
            // Attention, on pars du principe que les tableaux contiennent 5 lignes
            // 0.Nom cocktail + 1.Origine + 2.Description + 3.Degre + 4.IdCatégorie
            objet.setObject(texte[0], forKey: colonne[0])
            objet.setObject(texte[1], forKey: colonne[1])
            objet.setObject(texte[2], forKey: colonne[2])
            objet.setObject(texte[3], forKey: colonne[3])
            // Pointeur vers la table Categories
            let objetCatId = PFObject(withoutDataWithClassName: "Categories", objectId: texte[4])
            objet[colonne[4]] = objetCatId
            // Image
            objet.setObject(fichierImage!, forKey: "photo_cocktail")
            // Pointeur vers user
            objet.setObject(PFUser.currentUser()!, forKey: "user")
            objet.saveInBackgroundWithBlock({ (ok:Bool, erreur:NSError?) -> Void in
                if(erreur == nil) {
                    // Si l'envoie de la publication est finie, on place le pointeur vers Ingredients
                    // Gestion des Ingrédients (5 à 7) et Quantités (8 à 10)
                    for compteur in 5...10 {
                        // Dans la table Composer_perso
                        let objetComposer = PFObject(className: "Composer_perso")
                        // Traitement des ingrédients
                        if(compteur == 5 || compteur == 6 || compteur == 7){
                            let objetIngrId = PFObject(withoutDataWithClassName: "Ingredients", objectId: texte[compteur])
                            objetComposer["ingredient"] = objetIngrId
                            // On place le pointeur vers Cocktail_perso
                            let cocktailPersoId = objet.objectId
                            // On place le pointeur vers Cocktail_perso dans la table Composer_perso
                            let objetCockId = PFObject(withoutDataWithClassName: "Cocktails_perso", objectId: cocktailPersoId)
                            // Nom de la colonne dans la table Composer_perso
                            objetComposer["cocktail_perso"] = objetCockId
                        } else {
                            // On écrit les quantités
                            var test = texte[compteur] as? Int
                            objetComposer.setObject(test!, forKey: "quantite")
                        }
                        objetComposer.saveInBackgroundWithBlock({ (ok:Bool, erreur:NSError?) -> Void in
                            if(erreur != nil) {
                                CaptureErreurs.erreurParDefaut(erreur!)
                            }
                        })
                    }
                    CaptureErreurs.informationParDefautString("Cocktail Partagé !")
                } else {
                    CaptureErreurs.erreurParDefaut(erreur!)
                }
            })
            self.user = PFUser.currentUser()
            self.photo_cocktail = fichierImage
            // FIN MODIF
            chargement.hide(true)
        }
        }
    }
    
    // Il va télécharger l'image et la stocker dans le cache. Si on a besoin de l'image, une autre fois, il ne
    // va pas la re-télécharger.
    func telechargerImage() {
        if let imageNil = self.image.value {
            // On attribut une valeur à l'image provenant du cache
            image.value = Publication.cacheImage[self.photo_cocktail!.name]
        }
        // Si l'image n'est pas encore téléchargée, on le fait
        if (image.value == nil) {
             photo_cocktail?.getDataInBackgroundWithBlock({ (donnee: NSData?, erreur: NSError?) -> Void in
                if (erreur == nil) {
                    let image = UIImage(data: donnee!, scale: 1.0)!
                    self.image.value = image
                    // On remplit le cache avec l'image
                    Publication.cacheImage[self.photo_cocktail!.name] = image
                }
            })
        }
    }
}


// MARK: PFSubclassing
extension Publication: PFSubclassing {
    static func parseClassName() -> String {
        // Nom de la table ciblée
        return "Cocktails_perso"
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // informe Parse de cette sous classe
            self.registerSubclass()
            // On cré un cache vide.
            Publication.cacheImage = NSCacheSwift<String, UIImage>()
        }
    }
}