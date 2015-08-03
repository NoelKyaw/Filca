//
//  ImageViewControllerCollectionViewController.swift
//  FlickrApp
//
//  Created by Kyaw Zay Yar Maung on 8/2/15.
//  Copyright (c) 2015 Kyaw Zay Yar Maung. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"

class ImageViewController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    // array keep track of all the searches
    var searches = [SearchResults]()
    
    // reference of object
    let flickr = Flickr()
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        textField.addSubview(activityIndicator)
        activityIndicator.frame = textField.bounds
        activityIndicator.startAnimating()

        flickr.searchTerm(textField.text) {
            results, error in
            activityIndicator.removeFromSuperview()
            if error != nil {
                println("Error searching : \(error)")
            }
            
            if results != nil {
                println("Found \(results!.searchResults.count) matching \(results!.searchTerm)")
                self.searches.insert(results!, atIndex: 0)
                self.collectionView?.backgroundColor = UIColor(red: 0x20/255, green: 0x0A/255, blue: 0x42/255, alpha:1.0)
                self.collectionView?.reloadData()
            }
        }
        
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func photoForIndexPath(indexPath: NSIndexPath) -> FlickrImage {
        return searches[indexPath.section].searchResults[indexPath.row]
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        println(segue.identifier)
        println(sender)
        
        if(segue.identifier == "showLarger"){
            let cell = sender as ImageCell
            
            println(cell)
            let indexPath = self.collectionView?.indexPathForCell(cell)
            println(indexPath)
            
            let flickrPhoto = photoForIndexPath(indexPath!)
            let vc = segue.destinationViewController as DetailViewController
            
            println(flickrPhoto.url)
            vc.imgID = flickrPhoto.imageID
            vc.imgUrl = flickrPhoto.url
            vc.largePhoto =  UIImage(data: NSData(contentsOfURL: NSURL(string: flickrPhoto.url)!)!)
            vc.destext = cell.descText.text
        }
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return searches.count
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searches[section].searchResults.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as ImageCell
        let image = photoForIndexPath(indexPath)
        cell.backgroundColor = UIColor.whiteColor()
        cell.imageView.image = image.thumbnail
        cell.descText.text = image.description
        return cell
    }
}
