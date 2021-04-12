//
//  Review.swift
//  Snacktacular
//
//  Created by Brishti Saha on 4/12/21.
//

import Foundation
import Firebase

class Review {
    var title: String
    var text: String
    var rating: Int
    var reviewUserID: String
    var date: Date
    var documentID: String
    
    var dictionary: [String: Any] {
        let timeIntervalDate = date.timeIntervalSince1970
        return ["title": title, "text": text, "rating": rating, "reviewUserID": reviewUserID, "date": timeIntervalDate]
    }
    
    
    init(title: String, text: String, rating: Int, reviewUserID: String, date: Date, documentID: String){
        self.title = title
        self.text = text
        self.rating = rating
        self.reviewUserID = reviewUserID
        self.date = date
        self.documentID = documentID
    }
    
    convenience init() {
        let reviewUserID = Auth.auth().currentUser?.uid ?? ""
        self.init(title: "", text: "", rating: 0, reviewUserID: "", date: Date(), documentID: "")
    }
    
    
    
    func saveData(spot: Spot, complettion: @escaping (Bool)-> ()){
        let db = Firestore.firestore()
        
        let dataToSave: [String: Any] = self.dictionary
        
        if self.documentID == "" {
            var ref: DocumentReference? = nil
            ref = db.collection("spots").document(spot.documentID).collection("reviews").addDocument(data: dataToSave) { (error) in
                guard error == nil else{
                    print("Error: adding document \(error!.localizedDescription)")
                    return complettion(false)
                }
                self.documentID = ref!.documentID
                print("Added document: \(self.documentID) to \(spot.documentID)")
                complettion(true)
            }
        } else{
            let ref = db.collection("spots").document(spot.documentID).collection("reviews").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                guard error == nil else{
                    print("Error: updating document \(error!.localizedDescription)")
                    return complettion(false)
                }
                print("Updated document: \(self.documentID) to \(spot.documentID)")
                complettion(true)
            }
        }
    }
}
