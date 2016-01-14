//
//  SuivreViewController.swift
//  Social Bartender
//
//  Created by nico on 28/11/2015.
//  Copyright © 2015 Nicolas Barthere. All rights reserved.
//

import UIKit
import ConvenienceKit
import Parse
import Foundation

class SuivreViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Stocke tous les utilisateurs qui matchent avec la recherche saisie
    var users: [PFUser]?
    
    /*
    C'est un cache local. Il stocke ts les utilisateurs que la personne suit.
    Utilisé pour mettre à jour le UI constamment après chaque intéraction au lieu 
    d'attendre la réponse du serveur
    */
    var followingUsers: [PFUser]? {
        didSet {
            /**
            La liste d'utilisateur suivit récupérée après que les cellules de la 
            tableView apparaissent. Au quel cas, on recharge les donnée pour 
            afficher le statut "suivit"
            */
            tableView.reloadData()
        }
    }
    
    // La requête parse
    var query: PFQuery? {
        didSet {
            // Dès qu'on donne une nvelle requête, on annule la précédente
            oldValue?.cancel()
        }
    }
    
    // La vue à deux états différents
    enum State {
        case DefaultMode
        case SearchMode
    }
    
    // Dès qu'un changement intervient, on exécute une des deux requêtes et
    // met à jour l'UI
    var state: State = .DefaultMode {
        didSet {
            switch (state) {
            case .DefaultMode:
                query = ParseRequete.tousUtilisateurs(updateList)
            case .SearchMode:
                let searchText = searchBar?.text ?? ""
                query = ParseRequete.chercherUtilisateur(searchText, completionBlock: updateList)
            }
        }
    }
    
    // MARK: Mettre à jour la liste user
    
    /**
    Est appellée quand completion block à finit ses requêtes
    Dès qu'une requête est finie, on met à jour la tableView
    */
    func updateList(results: [PFObject]?, error: NSError?) {
        self.users = results as? [PFUser] ?? []
        self.tableView.reloadData()
        //    if let erreur = erreur {
        //      CaptureErreurs.erreurParDefaut(erreur)
        //    }
        
    }
    
    // MARK: Vue Globale
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        state = .DefaultMode
        
        // remplit le cache avec le user suivit
        ParseRequete.recupFollowers(PFUser.currentUser()!) {
            (results: [PFObject]?, error: NSError?) -> Void in
            let relations = results! as [PFObject] ?? []
            // utilise map pour extraire le user de l'objet suivre
            self.followingUsers = relations.map {
                $0.objectForKey(ParseRequete.ParseSuivreVersUser) as! PFUser
            }
            //    if let erreur = erreur {
            //      CaptureErreurs.erreurParDefaut(erreur)
            //    }
        }
    }
    
}

// MARK: TableView Data Source

extension SuivreViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MaCellule") as! SuivreTableViewCell
        
        let user = users![indexPath.row]
        cell.utilisateur = user
        
        if let followingUsers = followingUsers {
            // Vérifie is le user courant est déjà suivit par le user loggué
            // Change l'état du bouton en fction du résultat
            cell.peutSuivre = !followingUsers.contains(user)
        }
        
        cell.delegate = self
        
        return cell
    }
}

// MARK: Searchbar Delegate

extension SuivreViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        state = .SearchMode
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        state = .DefaultMode
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        ParseRequete.chercherUtilisateur(searchText, completionBlock:updateList)
    }
    
}

// MARK: SuivreViewControllerCell Delegate

extension SuivreViewController: SuivreTableViewCellDelegate {
    
    func cell(cell: SuivreTableViewCell, didSelectFollowUser user: PFUser) {
        ParseRequete.ajouterFollower(PFUser.currentUser()!, versUtilisateur: user)
        // Met à jour le cache local
        followingUsers?.append(user)
    }
    
    func cell(cell: SuivreTableViewCell, didSelectUnfollowUser user: PFUser) {
        if var followingUsers = followingUsers {
            ParseRequete.supprimerFollower(PFUser.currentUser()!, versUtilisateur: user)
            // Met à jour le cache local
            removeObject(user, fromArray: &followingUsers)
            self.followingUsers = followingUsers
        }
    }
    
    // Voir: http://stackoverflow.com/questions/24938948/array-extension-to-remove-object-by-value
    private func removeObject<T : Equatable>(object: T, inout fromArray array: [T])
    {
        let index = array.indexOf(object)
        if let index = index {
            array.removeAtIndex(index)
        }
    }
    
}
