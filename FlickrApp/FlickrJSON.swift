//
//  FlickrJSON.swift
//  FlickrApp
//
//  Created by Kyaw Zay Yar Maung on 8/2/15.
//  Copyright (c) 2015 Kyaw Zay Yar Maung. All rights reserved.
//

import Foundation
import UIKit

let apiKey = "3f913ff68442ecca0433083f01eaff77"

struct SearchResults {
    let searchTerm : String
    let searchResults: [FlickrImage]
}

class FlickrImage: Equatable{
    var thumbnail: UIImage?
    var Image: UIImage?
    
    let imageID: String
    let farm: Int
    let secret: String
    let server: String
    let description: String
    let url: String
    
    init(imageID:String, farm:Int, secret:String, server:String,description:String, url:String){
        self.imageID = imageID;
        self.farm = farm;
        self.secret = secret;
        self.server = server;
        self.description = description;
        self.url = url;
    }
    
    func flickrImageUrl(size:String = "m") -> NSURL {
        return NSURL(string: "http://farm\(farm).staticflickr.com/\(server)/\(imageID)_\(secret)_\(size).jpg")!;
    }
    
    
    func loadImage(completion: (flickrImage: FlickrImage, error: NSError?) -> Void){
        let getUrl = flickrImageUrl(size: "b")
        let getRequest = NSURLRequest(URL: getUrl)
        NSURLConnection.sendAsynchronousRequest(getRequest,
            queue: NSOperationQueue.mainQueue()) {
                response, data, error in
                
                if error != nil {
                    completion(flickrImage: self, error: error)
                    return
                }
                
                if data != nil {
                    let returnedImage = UIImage(data: data)
                    self.Image = returnedImage
                    completion(flickrImage: self, error: nil)
                    return
                }
                completion(flickrImage: self, error: nil)
        }
    }
    
    func loadImageFormDB(completion: (flickrImage: FlickrImage, error: NSError?) -> Void){
        
    }

}

func == (lhs:FlickrImage, rhs:FlickrImage) -> Bool{
    return lhs.imageID == rhs.imageID
}

class Flickr {
    
    let processingQueue = NSOperationQueue()
    
    func searchTerm(searchTerm: String, completion : (results: SearchResults?, error : NSError?) -> Void){
        
        let searchURL = flickrSearchURLForSearchTerm(searchTerm)
        let searchRequest = NSURLRequest(URL: searchURL)
        NSURLConnection.sendAsynchronousRequest(searchRequest, queue: processingQueue) {response, data, error in
            if error != nil {
                completion(results: nil,error: error)
                return
            }
            
            var JSONError : NSError?
            let resultsDictionary = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions(0), error: &JSONError) as? NSDictionary
            if JSONError != nil {
                completion(results: nil, error: JSONError)
                return
            }
            
            switch (resultsDictionary!["stat"] as String) {
            case "ok":
                println("Results processed OK")
            case "fail":
                let APIError = NSError(domain: "FlickrApp", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:resultsDictionary!["message"]!])
                completion(results: nil, error: APIError)
                return
            default:
                let APIError = NSError(domain: "FlickrApp", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Uknown API response"])
                completion(results: nil, error: APIError)
                return
            }
            
            let imageContainer = resultsDictionary!["photos"] as NSDictionary
            let imageReceived = imageContainer["photo"] as [NSDictionary]
            
            let flickrImages : [FlickrImage] = imageReceived.map {
                imageDictionary in
                
                let imageID = imageDictionary["id"] as? String ?? ""
                let farm = imageDictionary["farm"] as? Int ?? 0
                let server = imageDictionary["server"] as? String ?? ""
                let secret = imageDictionary["secret"] as? String ?? ""
                let desc = imageDictionary["title"] as? String ?? ""
                let url = imageDictionary["url_l"] as? String ?? ""
                
                let flickrImage = FlickrImage(imageID: imageID, farm: farm, secret: secret, server: server, description:  desc , url:url)
                
                let imageData = NSData(contentsOfURL: flickrImage.flickrImageUrl())
                flickrImage.thumbnail = UIImage(data: imageData!)
                
                return flickrImage
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                completion(results:SearchResults(searchTerm: searchTerm, searchResults: flickrImages), error: nil)
            })
        }
    }
    
    private func flickrSearchURLForSearchTerm(searchTerm:String) -> NSURL {
        
        let escapedTerm = searchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=\(escapedTerm)&per_page=30&extras=url_l&format=json&nojsoncallback=1"
        
        println(URLString)
        return NSURL(string: URLString)!
    }
    
    
}