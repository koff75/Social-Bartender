//
//  DetailCocktailViewController.swift
//  Social Bartender
//
//  Created by nico on 18/11/2015.
//  Copyright © 2015 Nicolas Barthere. All rights reserved.
//

import UIKit

class DetailCocktailViewController: UIViewController, NRFManagerDelegate {
    
    // Contient la donnée de l'objet cellule sélectionnée
    var currentObject : PFObject?

    @IBOutlet weak var nomLabel: UILabel!
    @IBOutlet weak var degreLabel: UILabel!
    @IBOutlet weak var origineLabel: UILabel!
    @IBOutlet weak var categorieLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var envoyerCocktailButton: UIButton!
    @IBOutlet weak var connecterButton: UIButton!
    @IBOutlet weak var deconnecterButton: UIButton!
    @IBOutlet weak var photoCocktailImageView: UIImageView!
    @IBOutlet weak var ingredient1Label: UILabel!
    @IBOutlet weak var ingredient2Label: UILabel!
    @IBOutlet weak var ingredient3Label: UILabel!
    @IBOutlet weak var quantiteUnLabel: UILabel!
    @IBOutlet weak var quantiteDeuxLabel: UILabel!
    @IBOutlet weak var quantiteTroisLabel: UILabel!
    
    
    var ingrListe: [String] = []
    var quantiteListe: [Int] = []
    
    // Bluetooth
    var nrfManager:NRFManager!
    var feedbackView = UITextView()

    var cocktailId:String?
    var categorieId:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Eviter les nils si pas de données dans Parse
        nomLabel.text = "Inconnu"
        degreLabel.text = "Inconnu"
        origineLabel.text = "Inconnu"
        categorieLabel.text = "Inconnu"
        descriptionLabel.text = "Inconnu"
        ingredient1Label.text = "Inconnu"
        ingredient2Label.text = "Inconnu"
        ingredient3Label.text = "Inconnu"
        quantiteUnLabel.text = "Inconnu"
        quantiteDeuxLabel.text = "Inconnu"
        quantiteTroisLabel.text = "Inconnu"
        
        if let updateObject = currentObject {
            cocktailId = updateObject.objectId
            nomLabel.text = updateObject["nom_cocktail"] as? String
            if (updateObject["degre_cocktail"] != nil) {
                degreLabel.text = updateObject["degre_cocktail"] as? String}
                //degreLabel.text = ("\(updateObject["degre_cocktail"] as! Int)")} CAST en INT
            if (updateObject["origine_cocktail"] != nil) {
                origineLabel.text = updateObject["origine_cocktail"] as? String}
            if (updateObject["nom_categorie"] != nil) {
                categorieId = updateObject["nom_categorie"].objectId
                // Récupère la catégorie
                recupererCategorie()
            }
            if (updateObject["description_cocktail"] != nil) {
                descriptionLabel.text = updateObject["description_cocktail"] as? String}
            if (updateObject["photo_cocktail"] != nil) {
                let fichierImage = updateObject["photo_cocktail"] as? PFFile
                fichierImage?.getDataInBackgroundWithBlock({ (image:NSData?, erreur:NSError?) -> Void in
                    if(image != nil) {
                        self.photoCocktailImageView.image = UIImage(data: image!)
                        self.photoCocktailImageView.contentMode = .ScaleAspectFill
                    }
                })
            }
        }
        

        // Récupère les ingrédients ET quantité
        recupererIngredients()
        


        // Bluetooth
       /* nrfManager = NRFManager(
            onConnect: {
                self.log("C: ★ Connecté")
            },
            onDisconnect: {
                self.log("C: ★ Déconnecté")
            },
            onData: {
                (data:NSData?, string:String?)->() in
                self.log("C: ⬇ Réception donnée - Chaîne: \(string) - Donnée: \(data)")
            },
            autoConnect: false
        )*/
        nrfManager = NRFManager.sharedInstance
        nrfManager.verbose = true
        nrfManager.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func fermerViewController(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    @IBAction func envoyerCocktailButtonTapped(sender: AnyObject) {
        envoyerCocktailButton.addTarget(self, action: "envoieCommande", forControlEvents: UIControlEvents.TouchUpInside)
        
        // Incrémente le compteur de consomation de cocktails sur Parse
        if let updateObject = currentObject {
            if (updateObject["nb_conso_cocktail"] != nil) {
                var nbConso:Int = updateObject["nb_conso_cocktail"] as! Int
                nbConso++
                updateObject["nb_conso_cocktail"] = nbConso
            } else {
                // Si le compteur n'est pas initialisé dans Parse
                updateObject["nb_conso_cocktail"] = 1
            }
            updateObject.saveInBackgroundWithBlock({ (ok:Bool, erreur:NSError?) -> Void in
                if(erreur != nil) {
                    CaptureErreurs.erreurParDefaut(erreur!)
                }
            })
            
        }
        
        
    }
    @IBAction func connecterButtonTapped(sender: AnyObject) {
        connecterButton.addTarget(nrfManager, action: "connect", forControlEvents: UIControlEvents.TouchUpInside)
    }
    @IBAction func deconnecterButtonTapped(sender: AnyObject) {
        deconnecterButton.addTarget(nrfManager, action: "disconnect", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func recupererCategorie() {
        // Va récupérer dans Parse les Catégories de Cocktails
        let objet = PFQuery(className: "Categories")
        objet.getObjectInBackgroundWithId(categorieId!) { (objet:PFObject?, erreur:NSError?) -> Void in
            if erreur == nil {
                let nom_categorie = objet!.objectForKey("nom_categorie") as! String
                self.categorieLabel.text! = nom_categorie
            }
        }
    }

    // Chercher tous les ingrédients d'un cocktail
    func recupererIngredients() {
        var cpt:Int = 0
        
        if(currentObject!.parseClassName == "Cocktails_base") {
            
            let requete = PFQuery(className: "Composer")
            let objetIngrId = PFObject(withoutDataWithClassName: "Cocktails_base", objectId: cocktailId!)
            requete.whereKey("cocktail_base", equalTo:objetIngrId)
            
            //requete.includeKey("ingredient")
            
            requete.findObjectsInBackgroundWithBlock { (resultats:[PFObject]?, erreur:NSError?) -> Void in
                for resultat in resultats! {
                    var ingreId = resultat["ingredient"].objectId
                    
                    // On récupère la quantité
                    var quantiteIngredient = resultat["quantite"] as! Int
                    self.quantiteListe.append(quantiteIngredient)
                    print(quantiteIngredient)
                    
                    let objetIngre = PFObject(withoutDataWithClassName: "Ingredients", objectId: ingreId)
                    let requete2 = PFQuery(className: "Ingredients")
                    requete2.whereKey("objectId", equalTo:objetIngre)
                    requete2.getObjectInBackgroundWithId(ingreId!!, block: { (objet:PFObject?, erreur:NSError?) -> Void in
                        var nom_ingredient = objet?.objectForKey("nom_ingredient") as! String
                        self.ingrListe.append(nom_ingredient)
                        print(nom_ingredient)
                        // On place les valeurs dans l'IHM
                        if (cpt == 0) {
                            self.ingredient1Label.text = nom_ingredient
                            self.quantiteUnLabel.text = "\(quantiteIngredient)"
                            cpt++
                        } else if(cpt == 1) {
                            self.ingredient2Label.text = nom_ingredient
                            self.quantiteDeuxLabel.text = "\(quantiteIngredient)"
                            cpt++
                        } else if (cpt == 2) {
                            self.ingredient3Label.text = nom_ingredient
                            self.quantiteTroisLabel.text = "\(quantiteIngredient)"
                            cpt++
                        }
                    })
                }
            }
        } else {
            let requete = PFQuery(className: "Composer_perso")
            let objetIngrId = PFObject(withoutDataWithClassName: "Cocktails_perso", objectId: cocktailId!)
            requete.whereKey("cocktail_perso", equalTo:objetIngrId)
            
            //requete.includeKey("ingredient")
            
            requete.findObjectsInBackgroundWithBlock { (resultats:[PFObject]?, erreur:NSError?) -> Void in
                for resultat in resultats! {
                    var ingreId = resultat["ingredient"].objectId
                    
                    // On récupère la quantité
                    var quantiteIngredient = resultat["quantite"] as! Int
                    self.quantiteListe.append(quantiteIngredient)
                    print(quantiteIngredient)
                    
                    let objetIngre = PFObject(withoutDataWithClassName: "Ingredients", objectId: ingreId)
                    let requete2 = PFQuery(className: "Ingredients")
                    requete2.whereKey("objectId", equalTo:objetIngre)
                    requete2.getObjectInBackgroundWithId(ingreId!!, block: { (objet:PFObject?, erreur:NSError?) -> Void in
                        var nom_ingredient = objet?.objectForKey("nom_ingredient") as! String
                        self.ingrListe.append(nom_ingredient)
                        print(nom_ingredient)
                        // On place les valeurs dans l'IHM
                        if (cpt == 0) {
                            self.ingredient1Label.text = nom_ingredient
                            self.quantiteUnLabel.text = "\(quantiteIngredient)"
                            cpt++
                        } else if(cpt == 1) {
                            self.ingredient2Label.text = nom_ingredient
                            self.quantiteDeuxLabel.text = "\(quantiteIngredient)"
                            cpt++
                        } else if (cpt == 2) {
                            self.ingredient3Label.text = nom_ingredient
                            self.quantiteTroisLabel.text = "\(quantiteIngredient)"
                            cpt++
                        }
                    })
                }
            }
        }
    }

    // Envoie du cocktail par bluetooth
    func envoieCommande()
    {
        let string = "2;0;1#"
        let result = self.nrfManager.writeString(string)
        log("⬆ Envoie Cocktail: \(string) - Result: \(result)")
        if(result == true) {
            CaptureErreurs.informationParDefautString("Cocktail Envoyé !")
        } else {
            CaptureErreurs.erreurParDefautString("Veuillez-ressayer...")
        }
    }
    
    // Permet de logguer les évènements produits par la trame bluetooth
    func log(string:String)
    {
        print(string)
        //feedbackView.text = feedbackView.text + "\(string)\n"
        //feedbackView.scrollRangeToVisible(NSMakeRange(feedbackView.text.characters.count , 1))
    }
    
    // MARK: - NRFManagerDelegate Methods

    func nrfDidConnect(nrfManager:NRFManager)
    {
        self.log("Etat : Connecté")
        CaptureErreurs.informationParDefautString("Social Bartender Connecté")
    }
    
    func nrfDidDisconnect(nrfManager:NRFManager)
    {
        self.log("Etat : Déconnecté")
        CaptureErreurs.informationParDefautString("Social Bartender Déconnecté")
    }
    
    func nrfReceivedData(nrfManager:NRFManager, data: NSData?, string: String?) {
        self.log("D: ⬇ Réception - Chaîne: \(string) - Donnée: \(data)")
    }

}
