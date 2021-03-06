//
//  ConfigurationViewController.swift
//  Social Bartender
//
//  Created by nico on 06/01/2016.
//  Copyright © 2016 Nicolas Barthere. All rights reserved.
//

import UIKit
import Parse

class ConfigurationViewController: UIViewController, NRFManagerDelegate {
    
    // Permet le stockage des valeurs sur le téléphone
    let clesIngre = NSUserDefaults.standardUserDefaults()
    enum clesIngredients {
        static let cleIngredient1 = "cleIngredient1"
        static let cleIngredient2 = "cleIngredient2"
        static let cleIngredient3 = "cleIngredient3"
    }
    
    // Bluetooth
    var nrfManager:NRFManager!
    var feedbackView = UITextView()
    
    // Variable de passage, pour la méthode reception
    var passage:Int?
    
    // Popup chargement pour l'envoie des ingrédients
    var chargement: MBProgressHUD = MBProgressHUD()
    
    @IBOutlet weak var recipientUnPickerView: UIPickerView!
    @IBOutlet weak var recipientDeuxPickerView: UIPickerView!
    @IBOutlet weak var recipientTroisPickerView: UIPickerView!
    @IBOutlet weak var ingredientUnLabel: UILabel!
    @IBOutlet weak var ingredientDeuxLabel: UILabel!
    @IBOutlet weak var ingredientTroisLabel: UILabel!
    @IBOutlet weak var enregistrerButton: UIButton!
    
    var ingredientUnSelectionne: String?
    var ingredientDeuxSelectionne: String?
    var ingredientTroisSelectionne: String?
    var ingredientsListeId:[String] = [String]()
    // Car findObjectInBackground est asynchrone et traitement lentement le requete
    // Pour l'attendre, il faut faire ceci
    var ingredientsListe: [String] = [] {
        didSet {
            recipientUnPickerView.reloadAllComponents()
            recipientDeuxPickerView.reloadAllComponents()
            recipientTroisPickerView.reloadAllComponents()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Requetes sur Parse pour rechercher les ingrédients dans la BDD, nom table: Ingredients
        recuperationIngredients()
        
        nrfManager = NRFManager.sharedInstance
        nrfManager.verbose = false
        nrfManager.delegate = self
        // Permet d'enlever le blanc, navigationController et status bar
        self.navigationController?.navigationBarHidden = true
        // Je monte de 20px qui correspondait à un blanc de la status bar (tweak)
        self.navigationController!.navigationBar.frame = CGRectOffset(self.navigationController!.navigationBar.frame, 0.0, -20.0);
        
        // A chaque fois qu'on ouvre la conf, on demande ce qu'à la machine
        passage = 0
        
        // On charge les clés des ingrédients stockées sur le téléphone
        if let ingr1 = clesIngre.stringForKey(clesIngredients.cleIngredient1) {
            self.ingredientUnLabel.text = ingr1
        }
        if let ingr2 = clesIngre.stringForKey(clesIngredients.cleIngredient2) {
            self.ingredientDeuxLabel.text = ingr2
        }
        if let ingr3 = clesIngre.stringForKey(clesIngredients.cleIngredient3) {
            self.ingredientTroisLabel.text = ingr3
        }

    }
    /*override func prefersStatusBarHidden() -> Bool {
        return true
    }*/
    
    func recuperationIngredients() {
        // Va récupérer dans Parse les ingrédients de Cocktails
        var objet = PFQuery(className: "Ingredients")
        objet.findObjectsInBackgroundWithBlock { (objets: [PFObject]?, erreur: NSError?) -> Void in
            if erreur == nil {
                for objet in objets! {
                    let categ:String = objet["nom_ingredient"] as! String
                    // Recupération du nom de l'ingrédient
                    self.ingredientsListe.append(categ)
                    // Recupération de l'id de l'ingrédient
                    self.ingredientsListeId.append(objet.objectId!)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Les PickerViews
    
    // Retourne le nombre de colonnes dans la pickerView
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1 // Une seule colonne
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return ingredientsListe.count
    }
    
    func pickerView(pickerView	: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
            return ingredientsListe[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == recipientUnPickerView) {
            return ingredientUnSelectionne = ingredientsListe[row]
        }
        else if (pickerView == recipientDeuxPickerView) {
            return ingredientDeuxSelectionne = ingredientsListe[row]
        }
        else {
            return ingredientTroisSelectionne = ingredientsListe[row]
        }
    }
    
    // MARK: Bouton Enregistrer
    @IBAction func enregistrerButtonTapped(sender: AnyObject) {
        // Popup de chargement
        let chargement = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        chargement.labelText = "Envoie des ingrédients"
        chargement.detailsLabelText = "Chargement en cours"
        // Lance une fois que la tache background à terminée
        dispatch_async(dispatch_get_main_queue()) {
            // Ferme la popup de chargement
            chargement.hide(true)
            // Attention: Si aucun pickerView touché par l'utilisateur, on prend la 1ère valeur
            if (self.ingredientUnSelectionne == nil) {
                self.ingredientUnSelectionne = self.ingredientsListe[0]
            }
            if (self.ingredientDeuxSelectionne == nil) {
                self.ingredientDeuxSelectionne = self.ingredientsListe[0]
            }
            if (self.ingredientTroisSelectionne == nil) {
                self.ingredientTroisSelectionne = self.ingredientsListe[0]
            }
            // Envoie ingrédient 1
            let ingr1:String = "1;0;1;"+self.ingredientUnSelectionne!+"#"
            self.envoyerCommande(ingr1)
            // Envoie ingrédient 2
            sleep(1)
            let ingr2:String = "1;0;2;"+self.ingredientDeuxSelectionne!+"#"
            self.envoyerCommande(ingr2)
            // Envoie ingrédient 3
            sleep(1)
            let ingr3:String = "1;0;3;"+self.ingredientTroisSelectionne!+"#"
            self.envoyerCommande(ingr3)
            // Si on revient sur la page Configuration, on redemande les ingrédients
            self.passage = 0
            self.envoyerCommande("2;0;1#")
            self.envoyerCommande("2;0;2#")
            self.envoyerCommande("2;0;3#")
        }
    }
    
    // MARK: Méthodes Bluetooth
    
    func envoyerCommande(codeCommande:String)
    {
        let result = self.nrfManager.writeString(codeCommande)
        log("⬆ Envoie commande: \(codeCommande) - Result: \(result)")
        if(result == false) {
            CaptureErreurs.erreurParDefautString("Problème de connexion")
        }
    }
    // Permet de logguer les évènements produits par la trame bluetooth
    func log(string:String)
    {
        print(string)
        feedbackView.text = feedbackView.text + "\(string)\n"
        feedbackView.scrollRangeToVisible(NSMakeRange(feedbackView.text.characters.count , 1))
    }
    
    func nrfDidConnect(nrfManager:NRFManager)
    {
        self.log("Etat : Connecté")
        // "2;0;1#" est le code qui demande à la machine ses ingrédients sockés
        envoyerCommande("2;0;1#")
        envoyerCommande("2;0;2#")
        envoyerCommande("2;0;3#")
    }
    
    func nrfDidDisconnect(nrfManager:NRFManager)
    {
        self.log("Etat : Déconnecté")
    }
    
    func nrfReceivedData(nrfManager:NRFManager, data: NSData?, string: String?) {
        self.log("D: ⬇ Réception - Chaîne: \(string) - Donnée: \(data)")
        // Si 1er passage, c'est la commande de demande du contenu machine
        //var tableauString = string?.componentsSeparatedByString("#")

        if(passage == 0) {
            ingredientUnLabel.text = string!
            //Enregistrement en dur dans l'application
            self.clesIngre.setValue(ingredientUnLabel.text, forKey: clesIngredients.cleIngredient1)
            passage!++
        } else if(passage == 1) {
            ingredientDeuxLabel.text = string!
            //Enregistrement en dur dans l'application
            self.clesIngre.setValue(ingredientDeuxLabel.text, forKey: clesIngredients.cleIngredient2)
            passage!++
        } else if(passage == 2) {
            ingredientTroisLabel.text = string!
            //Enregistrement en dur dans l'application
            self.clesIngre.setValue(ingredientTroisLabel.text, forKey: clesIngredients.cleIngredient3)
            passage!++
        }
    }


}
