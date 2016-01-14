//
//  PagePrincipaleViewController.swift
//  Social Bartender
//
//  Created by nico on 07/11/2015.
//  Copyright © 2015 Nicolas Barthere. All rights reserved.
//

import UIKit
import Parse

var countries = [PFObject]()

class PagePrincipaleViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Resize size of collection view items in grid so that we achieve 3 boxes across
        let cellWidth = ((UIScreen.mainScreen().bounds.width) - 32 - 30 ) / 3
        // Get a reference to the collection view layout object. We will use this object to configure the cell size.
        let cellLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        // Update the cellLayout object to our earlier calculated width and use the same value for cell height.
        cellLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func MenuButtonItem(sender: AnyObject) {
        // Active le panneau de Gauche (Menu)
        var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.contenuDrawer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    // Load data into the collectionView when the view appears
    override func viewDidAppear(animated: Bool) {
        loadCollectionViewData()
    }
    
    func loadCollectionViewData() {
        
        // Build a parse query object
        var query = PFQuery(className:"Cocktails")
        
        // Check to see if there is a search term
        if searchBar.text != "" {
            query.whereKey("searchText", containsString: searchBar.text!.lowercaseString)
        }
        
        // Fetch data from the parse platform
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error:NSError?) -> Void in
            
            // The find succeeded now rocess the found objects into the countries array
            if error == nil {
                
                // Clear existing country data
                countries.removeAll(keepCapacity: true)
                
                // Add country objects to our array "PAS SUR DU !"
                if let objects = objects as? [PFObject]! {
                    countries = Array(objects.generate())
                }
                
                // reload our data into the collection view
                self.collectionView.reloadData()
                
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countries.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MaCellule", forIndexPath: indexPath) as! RechercherCollectionViewCell
        
        // Display the country name
        if let value = countries[indexPath.row]["nom"] as? String {
            cell.celluleLabel.text = value
        }
        
        // Display "initial" flag image
        var initialThumbnail = UIImage(named: "question")
        cell.celluleImageView.image = initialThumbnail
        
        // Fetch final flag image - if it exists
        if let value = countries[indexPath.row]["flag"] as? PFFile {
            let finalImage = countries[indexPath.row]["flag"] as? PFFile
            finalImage!.getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        cell.celluleImageView.image = UIImage(data:imageData)
                    }
                }
            }
        }
        return cell
    }
    
    /* Wire up the “To Detail View” segue */
    
    // Process collectionView cell selection
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let currentObject = countries[indexPath.row]
        performSegueWithIdentifier("CollectionViewToDetailView", sender: currentObject)
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // If a cell has been selected within the colleciton view - set currentObjact to selected
        var currentObject : PFObject?
        if let country = sender as? PFObject{
            currentObject = sender as? PFObject
        } else {
            // No cell selected in collectionView - must be a new country record being created
            currentObject = PFObject(className:"Countries")
        }
        
        // Get a handle on the next story board controller and set the currentObject ready for the viewDidLoad method
        var detailScene = segue.destinationViewController as! DetailViewController
        detailScene.currentObject = (currentObject)
    }
    
    
}
