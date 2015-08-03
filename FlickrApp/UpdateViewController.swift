//
//  UpdateViewController.swift
//  FlickrApp
//
//  Created by Kyaw Zay Yar Maung on 9/2/15.
//  Copyright (c) 2015 Kyaw Zay Yar Maung. All rights reserved.
//

import UIKit

class UpdateViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var commentText: UITextField!
    
    var url:String = ""
    var largePhoto :UIImage?
    var comment :String?
    var id:Int?
    
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
        commentText.text = comment
        commentText.delegate = self
        println(url)
        openConnection()
        
        // Do any additional setup after loading the view.
        // navigationController.setNavigationBarHidden(false, animated:true)
    }
    
    override func viewWillAppear(animated: Bool) {
        commentText.text = comment
    }
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
        var cSql = sqlString.cStringUsingEncoding(NSUTF8StringEncoding)
        
        sqlString = "SELECT url, comment FROM FAV WHERE imgid=?"
        cSql = sqlString.cStringUsingEncoding(NSUTF8StringEncoding)
        sqlite3_prepare_v2(favDB, cSql!, -1, &selectStatement, nil)
        
        sqlString = "UPDATE FAV SET comment = ? WHERE url = ?"
        cSql = sqlString.cStringUsingEncoding(NSUTF8StringEncoding)
        sqlite3_prepare_v2(favDB, cSql!, -1, &updateStatement, nil)
        
        sqlString = "DELETE FROM FAV WHERE URL = ?"
        cSql = sqlString.cStringUsingEncoding(NSUTF8StringEncoding)
        sqlite3_prepare_v2(favDB, cSql!, -1, &deleteStatment, nil)
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
    
    func updateFav(sender: AnyObject){
//        var idStr = (id as NSInteger)
        var imgurlStr = (url as NSString).UTF8String
        var commentStr = (commentText.text as NSString).UTF8String
        
        sqlite3_bind_text(updateStatement, 1, commentStr, -1, nil)
        sqlite3_bind_text(updateStatement, 2, imgurlStr, -1, nil)

        
        if (sqlite3_step(updateStatement) == SQLITE_DONE){
            statusLabel.text = "Favourite updated!"
        } else {
            statusLabel.text = "Failed to update favourite"
            println("Error code: ", sqlite3_errcode(favDB))
            let error = String.fromCString(sqlite3_errmsg(favDB))
            println("Error Msg: ", error)
        }
        
        sqlite3_reset(updateStatement)
        sqlite3_clear_bindings(updateStatement)
    }
    
    func deleteFav(sender: AnyObject){
        var imgurlStr = (url as NSString).UTF8String
        sqlite3_bind_text(deleteStatment, 1, imgurlStr, -1, nil)
        
        if (sqlite3_step(deleteStatment) == SQLITE_DONE){
            statusLabel.text = "Image deleted!"
        } else {
            statusLabel.text = "Failed to delete favourite"
            println("Error code: ", sqlite3_errcode(favDB))
            let error = String.fromCString(sqlite3_errmsg(favDB))
            println("Error Msg: ", error)
        }
        
        sqlite3_reset(deleteStatment)
        sqlite3_clear_bindings(deleteStatment)
    }
    
    @IBAction func updatefavourite(sender: AnyObject) {
        updateFav(self)
    }
    
    @IBAction func deleteFavourite(sender: AnyObject) {
        deleteFav(self)
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func shareSheet(sender: AnyObject){
        
        let firstActivityItem = "Hey, look what i found from flickr today!"
        let secondActivityItem = url
        let thirdAcitivityItem = largePhoto as UIImage!
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem, secondActivityItem, thirdAcitivityItem], applicationActivities: nil)
        
        activityViewController.excludedActivityTypes = [
            UIActivityTypePostToVimeo,
        ]
        
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
