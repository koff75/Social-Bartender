//
//  AccueilViewController.swift
//  Social Bartender
//
//  Created by nico on 17/11/2015.
//  Copyright © 2015 Nicolas Barthere. All rights reserved.
//

import UIKit

class AccueilViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Supprime la Top Bar Navigation de la vue
        self.navigationController?.navigationBar.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func facebookButtonTapped(sender: AnyObject) {
        // Appel d'une autre vue comportant la méthode pour s'identifier sur Facebook
        // avec récupération de la photo de profil
        ViewController().facebookButtonTapped(sender)
    }


}
