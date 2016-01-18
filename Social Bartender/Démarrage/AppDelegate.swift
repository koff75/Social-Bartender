//
//  AppDelegate.swift
//  Social Bartender
//
//  Created by nico on 06/11/2015.
//  Copyright © 2015 Nicolas Barthere. All rights reserved.
//

import UIKit
import Parse
import Bolts
import ParseFacebookUtilsV4

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var contenuDrawer: MMDrawerController?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Parse.enableLocalDatastore()
        // Initialisation de Parse
        Parse.setApplicationId("ahbi3dbt6XadI17ErdjhIoM51n1N3mKaPEHFeKD5",
            clientKey: "zqUyUNHoNYNCvrJDT7MgDtJ0ewfqFme57g1Bgg8p")
        // Modifications des ACL
        //let acl = PFACL()
        // A VERIFIER : noramelement c'est setPublicReadAccess mais je tenterai setReadAccess
        //acl.publicReadAccess = true
        //PFACL.setDefaultACL(acl, withAccessForCurrentUser: true)
        
        // Initialisation du module Facebook
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        creationInterfaceUtilisateur()
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func creationInterfaceUtilisateur() {
        /* Copie de la fonction provenant du fichier ViewController.swift */
        // Permet de Lire le nom de l'utilisateur stocké
        let nomUtilisateur = NSUserDefaults.standardUserDefaults().stringForKey("nom_utilisateur")
        // Si l'utilisateur est enregistré, on lui éviter de resaisir ses identifiants
        if(nomUtilisateur != nil){
            // Navigation vers une page protégée quand l'utilisateur à bien rentré ses identifiants
            let mainStoryBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            // Va instancier (créer) la PagePrincipaleViewController
            var pagePrincipale:RechercherCocktailViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("RechercherCocktailViewController2") as! RechercherCocktailViewController
            // Va instancier CoteDroitViewController
            var menuCoteDroit:CoteDroitViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("CoteDroitViewController") as! CoteDroitViewController
            // Va instancier CoteGaucheViewController
            var menuCoteGauche:CoteGaucheViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("CoteGaucheViewController") as! CoteGaucheViewController
            
            // Va connecter vers la Navigation Controller
            var pagePrincipaleNav = UINavigationController(rootViewController: pagePrincipale)
            var menuCoteDroitNav = UINavigationController(rootViewController: menuCoteDroit)
            var menuCoteGaucheNav = UINavigationController(rootViewController: menuCoteGauche)
            
            // Connexion du menu gauche et droit
            contenuDrawer = MMDrawerController(centerViewController: pagePrincipaleNav, leftDrawerViewController: menuCoteGaucheNav, rightDrawerViewController: menuCoteDroitNav)
            // Taille du bandeau de gauche a 160. Possibilité 200 - 240 - 280 - 320
            
            contenuDrawer?.maximumLeftDrawerWidth = 160

            // Ouvrir le menu en prenant le bord gauche de l'écran
            contenuDrawer!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.BezelPanningCenterView
            
            // Fermer le menu
            contenuDrawer!.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.BezelPanningCenterView//.PanningCenterView
            
            // (plus besoin) var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            window?.rootViewController = contenuDrawer
        }
    }


}

