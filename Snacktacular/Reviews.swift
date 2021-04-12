//
//  Reviews.swift
//  Snacktacular
//
//  Created by Brishti Saha on 4/12/21.
//

import Foundation
import Firebase

class Reviews {
    
    var reviewsArray: [Review] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(spot: Spot, completed: @escaping () ->()) {
        guard spot.documentID != "" else{
            return
        }
        db.collection("spots").document(spot.documentID).collection("reviews").addSnapshotListener { (querySnapShot, error) in
            guard error == nil else{
                print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.reviewsArray = []
            for document in querySnapShot!.documents {
                let review = Review(dictionary: document.data())
                review.documentID = document.documentID
                self.reviewsArray.append(review)
            }
            completed()
        }
    }
}
