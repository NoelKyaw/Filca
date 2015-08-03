//
//  FavViewController.swift
//  FlickrApp
//
//  Created by Kyaw Zay Yar Maung on 9/2/15.
//  Copyright (c) 2015 Kyaw Zay Yar Maung. All rights reserved.
//

import UIKit

class FavViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    let reuseIdentifier = "FavCell"
    
    var favDB: COpaquePointer = nil; // pointer to the database
    var insertStatment: COpaquePointer = nil; // pointer to the prepared statment
    var selectStatement: COpaquePointer = nil;
    var updateStatement: COpaquePointer = nil;
    var deleteStatment: COpaquePointer = nil;
    var selectAllStatment: COpaquePointer = nil;
    
    var sqlString: String = ""
    var array_photos: NSMutableArray! = []
    var comments: NSMutableArray! = []
    var id: NSMutableArray! = []
    
    var image :UIImage?
    var imageid:String = ""
    var imageurl: String = ""
    var comment: String = ""
    
    @IBOutlet weak var imageView: UIImageView!
    
//    var photos: [Flick.Photo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        openConnection()
        //deleteAll(self)
        selectAllFunc(self)
        viewWillAppear(true)
        self.collectionView?.reloadData()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.collectionView?.reloadData()
        selectAllFunc(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        selectAllFunc(self)
    }
    
    func selectAllFunc(sender: AnyObject){
        
        sqlString = "SELECT ID, URL, COMMENT FROM FAV"
        var cSql = sqlString.cStringUsingEncoding(NSUTF8StringEncoding)
        sqlite3_prepare_v2(favDB, cSql!, -1, &selectAllStatment, nil)
        
        array_photos.removeAllObjects()
        comments.removeAllObjects()
        
        while (sqlite3_step(selectAllStatment) == SQLITE_ROW){
            var Dictionary = NSMutableDictionary()
            
            let id_buf = sqlite3_column_text(selectAllStatment, 0)
            let url_buf = sqlite3_column_text(selectAllStatment, 1)
            let comment_buf = sqlite3_column_text(selectAllStatment, 2)
            
            id.addObject(String.fromCString(UnsafePointer<CChar>(id_buf))!)
            array_photos.addObject(String.fromCString(UnsafePointer<CChar>(url_buf))!)
            comments.addObject(String.fromCString(UnsafePointer<CChar>(comment_buf))!)
        }
    }
    
//    func deleteAll(sender: AnyObject){
//        sqlString = "DELETE FROM FAV"
//        var cSql = sqlString.cStringUsingEncoding(NSUTF8StringEncoding)
//        sqlite3_prepare_v2(favDB, cSql!, -1, &deleteStatment, nil)
//        
//        if (sqlite3_step(deleteStatment) == SQLITE_DONE){
//            println("Contact Deleted!")
//        } else {
//            println("Failed to retrieve contact")
//            println("Error Code: ", sqlite3_errcode(favDB))
//            let error = String.fromCString(sqlite3_errmsg(favDB))
//            println("Error Msg: ", error)
//        }
//        
//        sqlite3_reset(deleteStatment)
//        sqlite3_clear_bindings(deleteStatment)
//    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println(segue.identifier)
        println(sender)
        
        if(segue.identifier == "showLarger")
        {
            let cell = sender as FavCell
            
            let row = self.collectionView?.indexPathForCell(cell)
            let indexPath :NSIndexPath = row!

            let vc = segue.destinationViewController as UpdateViewController
            vc.id = id[indexPath.row] as? Int
            vc.url = array_photos[indexPath.row] as String
            vc.comment = comments[indexPath.row] as? String
            vc.largePhoto = UIImage(data: NSData(contentsOfURL: NSURL(string: array_photos[indexPath.row] as String)!)!)
        }

    }

    // MARK: UICollectionViewDataSourc

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
      return array_photos.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as FavCell
        var photo_url: String = array_photos[indexPath.row] as String
        image = UIImage(data: NSData(contentsOfURL: NSURL(string: photo_url)!)!)
        cell.imageView.image = image
        return cell
       
    }
}
