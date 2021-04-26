//
//  SpotPhotoCollectionViewCell.swift
//  Snacktacular
//
//  Created by Brishti Saha on 4/26/21.
//

import UIKit

class SpotPhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    var spot: Spot!
    
    var photo: Photo! {
        didSet {
            photo.loadImage(spot: spot) { (success) in
                if success {
                    self.photoImageView.image = self.photo.image
                }else {
                    print("Error: no success in loading photo in SpotPhotoCollectionViewCell")
                }
            }
        }
    }
}
