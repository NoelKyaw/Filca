//
//  DetailViewController.swift
//  FlickrApp
//
//  Created by Kyaw Zay Yar Maung on 8/2/15.
//  Copyright (c) 2015 Kyaw Zay Yar Maung. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var favButton: UIButton!
    
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var commentText: UITextField!
    
    private var selectedPhotos = [FlickrImage]()
    
    var destext: String?
    var largePhoto :UIImage?
    var imgUrl: String = ""
    var imgID: String = ""
    
    var favDB: COpaquePointer = nil; // pointer to the database
    var insertStatment: COpaquePointer = nil; // pointer to the prepared statment
    var selectStatement: COpaquePointer = nil;
    var updateStatement: COpaquePointer = nil;
    var deleteStatment: COpaquePointer = nil;
    var selectAllStatment: COpaquePointer = nil;
    
    var sqlString: String = ""
    var array_data: NSMutableArray! = []
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool{
        commentText.resignFirstResponder()
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = largePhoto
        desLabel.text = destext
        println(imgUrl)
        println(imgID)
        
        commentText.delegate = self
        openConnection()
    }
    
    struct getindexPath{
        static var indexpath: NSIndexPath!
        static var searches = [SearchResults]()
    }
    
    @IBAction func addtofavourite(sender: AnyObject) {
        createFav(self)
    }
    
    @IBAction func shareSheet(sender: AnyObject){
        
        let firstActivityItem = "Hey, look what i found from flickr today!"
        let secondActivityItem = imgUrl
        let thirdAcitivityItem = largePhoto as UIImage!
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem, secondActivityItem, thirdAcitivityItem], applicationActivities: nil)
        
        activityViewController.excludedActivityTypes = [
            UIActivityTypePostToVimeo,
        ]
        
        self.presentViewController(activityViewController, animated: true, completion: nil)    }

    
    func openConnection(){
        
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) [0] as String
        var docsDir = paths.stringByAppendingPathComponent("Fav.sqlite")
        
        println(paths)
        println(docsDir)
        
        if (sqlite3_open(docsDir, &favDB) == SQLITE_OK) {
            var sql = "CREATE TABLE IF NOT EXISTS FAV (ID INTEGER PRIMARY KEY AUTOINCREMENT, IMGID TEXT, URL TEXT, COMMENT TEXT)"
            var statement:COpaquePointer = nil
            
            if (sqlite3_exec(favDB, sql, nil, nil,nil) != SQLITE_OK) {
                println("Failed to create table")
                println(sqlite3_errmsg(favDB))
            }
        } else {
            println("Failed to open database")
            println(sqlite3_errmsg(favDB))
        }
        prepareStatment();
    }
    
    func prepareStatment(){
        sqlString = "INSERT INTO FAV (imgid, url, comment) VALUES (?,?,?)"
        var cSql = sqlString.cStringUsingEncoding(NSUTF8StringEncoding)
        sqlite3_prepare_v2(favDB, cSql!, -1, &insertStatment, nil)
    }
    
    func createFav(sender: AnyObject){
        
        var imgidStr = (self.imgID as NSString).UTF8String
        var imgurlStr = (self.imgUrl as NSString).UTF8String
        var commentStr = (commentText.text as NSString).UTF8String
        
        sqlite3_bind_text(insertStatment, 1, imgidStr, -1, nil)
        sqlite3_bind_text(insertStatment, 2, imgurlStr, -1, nil)
        sqlite3_bind_text(insertStatment, 3, commentStr, -1, nil)
    
        if(sqlite3_step(insertStatment) == SQLITE_DONE){
            println ("Photos added");
            println(imgidStr)
            statusLabel.text = "Saved to Favourites"
        }else{
            println("Error code : ", sqlite3_errcode(favDB));
            let error = String.fromCString(sqlite3_errmsg(favDB));
            println("Error msg : ", error);
        }
        sqlite3_reset(insertStatment);
        sqlite3_clear_bindings(insertStatment);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        animateViewMoving(true, moveValue: 220)
    }
    func textFieldDidEndEditing(textField: UITextField) {
        animateViewMoving(false, moveValue: 220)
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        var movementDuration:NSTimeInterval = 0.3
        var movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }
    
    func getphoto(indexPath: NSIndexPath) -> FlickrImage {
        return ImageCell.getindexPath.searches[indexPath.section].searchResults[indexPath.row]
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
