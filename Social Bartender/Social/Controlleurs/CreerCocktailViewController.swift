//
//  CreerCocktailViewController.swift
//  Social Bartender
//
//  Created by nico on 18/11/2015.
//  Copyright © 2015 Nicolas Barthere. All rights reserved.
//

import UIKit
import Parse

class CreerCocktailViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var photoCocktailImageView: UIImageView!
    @IBOutlet weak var nomCocktailTextField: UITextField!
    @IBOutlet weak var origineCocktailTextField: UITextField!
    @IBOutlet weak var degreCocktailPickerView: UIPickerView!
    @IBOutlet weak var categorieCocktailPickerView: UIPickerView!
    @IBOutlet weak var descriptionCocktailTextView: UITextView!
    @IBOutlet weak var enregistrerCocktailButton: UIButton!
    @IBOutlet weak var ingredientUnPickerView: UIPickerView!
    @IBOutlet weak var ingredientDeuxPickerView: UIPickerView!
    @IBOutlet weak var ingredientTroisPickerView: UIPickerView!
    @IBOutlet weak var quantiteUnPickerView: UIPickerView!
    @IBOutlet weak var quantiteDeuxPickerView: UIPickerView!
    @IBOutlet weak var quantiteTroisPickerView: UIPickerView!
    
    // Degré :
    var degreAlcool = ["0","1","2","3","4","5","6","7","8","9"]
    var degreSelectionne1: String = ""
    var degreSelectionne2: String = ""
    
    // Catégorie :
    var categorieSelectionneId: String?
    var categorieListeId:[String] = [String]()
    // Car findObjectInBackground est asynchrone et traitement lentement le requete
    // Pour l'attendre, il faut faire ceci
    var categorieListe: [String] = [] {
        didSet {
            //self.categorieListeTemp = categorieListe
            categorieCocktailPickerView.reloadAllComponents()
        }
    }
    
    // Ingrédients :
    var ingredientUnSelectionneId: String?
    var ingredientDeuxSelectionneId: String?
    var ingredientTroisSelectionneId: String?
    var ingredientsListeId:[String] = [String]()
    var ingredientsListe: [String] = [] {
        didSet {
            ingredientUnPickerView.reloadAllComponents()
            ingredientDeuxPickerView.reloadAllComponents()
            ingredientTroisPickerView.reloadAllComponents()
        }
    }
    
    // Quantités :
    var quantiteListe = ["0","1","2","3","4","5","6","7","8","9","10"]
    var quantiteUnSelectionne: String?
    var quantiteDeuxSelectionne: String?
    var quantiteTroisSelectionne: String?

    
    var prendrePhotoHelper: PrendrePhotoHelper!
    // Contient toutes les publications suivit
    var publications: [Publication] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Permet de capturer le bouton 'retour' et fermera le clavier
        nomCocktailTextField.delegate = self
        origineCocktailTextField.delegate = self
        descriptionCocktailTextView.delegate = self
        
        recuperationCategories()
        recuperationIngredients()
    }
    
    func recuperationCategories() {
        // Va récupérer dans Parse les Catégories de Cocktails
        var objet = PFQuery(className: "Categories")
        objet.findObjectsInBackgroundWithBlock { (objets: [PFObject]?, erreur: NSError?) -> Void in
            if erreur == nil {
                for objet in objets! {
                    let categ:String = objet["nom_categorie"] as! String
                    // Recupération du nom de la catégorie
                    self.categorieListe.append(categ)
                    // Recupération de l'id de la catégorie
                    self.categorieListeId.append(objet.objectId!)
                }
            }
            //print("Avant Catégorie List is \(self.categorieListe)")
        }
        //print("Apres Catégorie List is \(self.categorieListe)")
        //categorieCocktailPickerView.reloadAllComponents()
    }
    
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
    
    // Retourne le nombre de colonnes dans la pickerView
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        if (pickerView == degreCocktailPickerView) {
            return 2 } // Deux colonnes
        else {
            return 1 // Une seule colonne
        }
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == degreCocktailPickerView) {
            return degreAlcool.count }
        else if (pickerView == categorieCocktailPickerView) {
            return categorieListe.count }
        else if (pickerView == ingredientUnPickerView || pickerView == ingredientDeuxPickerView || pickerView == ingredientTroisPickerView){
            return ingredientsListe.count
        } else {
            return quantiteListe.count
        }
    }
    
    func pickerView(pickerView	: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if (pickerView == degreCocktailPickerView) {
            return degreAlcool[row] }
        else if (pickerView == categorieCocktailPickerView) {
            return categorieListe[row] }
        else if (pickerView == ingredientUnPickerView || pickerView == ingredientDeuxPickerView || pickerView == ingredientTroisPickerView){
            return ingredientsListe[row]
        } else {
            return quantiteListe[row]
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == degreCocktailPickerView) {
            if(component == 0) {
               return degreSelectionne1 = degreAlcool[row]
            } else {
                return degreSelectionne2 = degreAlcool[row]
            }
        }
        else if (pickerView == categorieCocktailPickerView) {
            return categorieSelectionneId = categorieListeId[categorieCocktailPickerView.selectedRowInComponent(0)]
        }
        else if (pickerView == ingredientUnPickerView) {
            return ingredientUnSelectionneId = ingredientsListeId[ingredientUnPickerView.selectedRowInComponent(0)]
        }
        else if (pickerView == ingredientDeuxPickerView) {
            return ingredientDeuxSelectionneId = ingredientsListeId[ingredientDeuxPickerView.selectedRowInComponent(0)]
        }
        else if (pickerView == ingredientTroisPickerView){
            return ingredientTroisSelectionneId = ingredientsListeId[ingredientTroisPickerView.selectedRowInComponent(0)]
        } else if(pickerView == quantiteUnPickerView){
            return quantiteUnSelectionne = quantiteListe[row]
        } else if(pickerView == quantiteDeuxPickerView){
            return quantiteDeuxSelectionne = quantiteListe[row]
        } else if(pickerView == quantiteTroisPickerView){
            return quantiteTroisSelectionne = quantiteListe[row]
        }
    }
    
    
    @IBAction func creerCocktailButtonTapped(sender: AnyObject) {
        // Attention: Si aucun pickerView touché par l'utilisateur, on prend la 1ère valeur
        if (self.degreSelectionne1 == "") {
            self.degreSelectionne1 = self.degreAlcool[0]
        }
        if (self.degreSelectionne2 == "") {
            self.degreSelectionne2 = self.degreAlcool[0]
        }
        if (self.categorieSelectionneId == nil) {
            self.categorieSelectionneId = self.categorieListeId[self.categorieCocktailPickerView.selectedRowInComponent(0)]
        }
        if (self.ingredientUnSelectionneId == nil) {
            self.ingredientUnSelectionneId = self.ingredientsListeId[self.ingredientUnPickerView.selectedRowInComponent(0)]
        }
        if (self.ingredientDeuxSelectionneId == nil) {
            self.ingredientDeuxSelectionneId = self.ingredientsListeId[self.ingredientDeuxPickerView.selectedRowInComponent(0)]
        }
        if (self.ingredientTroisSelectionneId == nil) {
            self.ingredientTroisSelectionneId = self.ingredientsListeId[self.ingredientTroisPickerView.selectedRowInComponent(0)]
        }
        
        
        // Concaténer les deux colonne du pickerView Degre
        let degreTotal = self.degreSelectionne1 + self.degreSelectionne2
        if (self.nomCocktailTextField.text?.isEmpty == false && self.origineCocktailTextField.text?.isEmpty == false && self.descriptionCocktailTextView.text.isEmpty == false) {
            let textes: [String] = [self.nomCocktailTextField.text!, self.origineCocktailTextField.text!, self.descriptionCocktailTextView.text!, degreTotal, self.categorieSelectionneId!, self.ingredientUnSelectionneId!, self.ingredientDeuxSelectionneId!, self.ingredientTroisSelectionneId!, self.quantiteUnSelectionne!, self.quantiteDeuxSelectionne!, self.quantiteTroisSelectionne!]
            // Attention : Nom des colonnes de la table Cocktails_perso
            let colonnes: [String] = ["nom_cocktail", "origine_cocktail", "description_cocktail", "degre_cocktail", "nom_categorie"]
            let publication = Publication()
            publication.image.value = self.photoCocktailImageView.image
            publication.envoyerPublication(textes, colonne: colonnes)
        } else {
            CaptureErreurs.erreurParDefautString("Veuillez remplir tous les champs!")
        }
    }
    
    @IBAction func selectionnerPhotoButtonTapped(sender: AnyObject) {
        // Instancier la classe et va fournir le callback quand la photo sera sélectionnée
        // Param 1 : la vue ou le popup va apparaitre
        prendrePhotoHelper = PrendrePhotoHelper(viewController: self.tabBarController!, callback: {(image: UIImage?) in
            //let publication = Publication()
            // Place l'image sélectionnée dans la classe Publication
            //publication.image.value = image!
            self.photoCocktailImageView.image = image!
            //publication.envoyerPublication()
        })
    }
    
    // appelé quand 'retour' . retourne NO pour ignorer
    func textFieldShouldReturn(textField: UITextField!) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
}
