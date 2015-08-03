//
//  ImageCell.swift
//  FlickrApp
//
//  Created by Kyaw Zay Yar Maung on 8/2/15.
//  Copyright (c) 2015 Kyaw Zay Yar Maung. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descText: UILabel!
    
    struct getindexPath{
        static var indexpath: NSIndexPath!
        static var searches = [SearchResults]()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selected = false
    }

    func getphoto(indexPath: NSIndexPath) -> FlickrImage {
        return ImageCell.getindexPath.searches[indexPath.section].searchResults[indexPath.row]
    }
}
