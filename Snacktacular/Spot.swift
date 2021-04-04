//
//  Spot.swift
//  Snacktacular
//
//  Created by Brishti Saha on 4/4/21.
//

import Foundation
import Firebase

class Spot {
    var name: String
    var address: String
    var averageRating: Double
    var numberOfReviews: Int
    var postingUserID: String
    var documentID: String
    
    var dictionary: [String: Any]{
        return ["name": name, "address": address, "averageRating": averageRating, "numberOfReviews": numberOfReviews, "postingUserID": postingUserID ]
    }
    
    init(name: String, address: String, averageRating: Double, numberOfReviews: Int, postingUserID: String, documentID: String){
        self.name = name
        self.address = address
        self.averageRating = averageRating
        self.numberOfReviews = numberOfReviews
        self.postingUserID = postingUserID
        self.documentID = documentID
    }
    
    convenience init(){
        self.init(name: "", address: "", averageRating: 0.0, numberOfReviews: 0, postingUserID: "", documentID: "")
    }
    
    convenience init(dictionary: [String: Any]){
        let name = dictionary["name"] as! String? ?? ""
        let address = dictionary["address"] as! String? ?? ""
        let averageRating = dictionary["averageRating"] as! Double? ?? 0.0
        let numberOfReviews = dictionary["numberOfReviews"] as! Int? ?? 0
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        //let documentID = dictionary["documentID"] as! String? ?? ""
        
        self.init(name: name, address: address, averageRating: averageRating, numberOfReviews: numberOfReviews, postingUserID: postingUserID, documentID: "")
    }
    
    func saveData(complettion: @escaping (Bool)-> ()){
        let db = Firestore.firestore()
        guard let postingUserID = Auth.auth().currentUser?.uid else {
            print("ERROR: Could not save data because we don't have a vaid postingUserID")
            return complettion(false)
        }
        self.postingUserID = postingUserID
        
        let dataToSave: [String: Any] = self.dictionary
        
        if self.documentID == "" {
            var ref: DocumentReference? = nil
            ref = db.collection("spots").addDocument(data: dataToSave) { (error) in
                guard error == nil else{
                    print("Error: adding document \(error!.localizedDescription)")
                    return complettion(false)
                }
                self.documentID = ref!.documentID
                print("Added document: \(self.documentID)")
                complettion(true)
            }
        } else{
            let ref = db.collection("spots").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                guard error == nil else{
                    print("Error: updating document \(error!.localizedDescription)")
                    return complettion(false)
                }
                print("Updated document: \(self.documentID)")
                complettion(true)
            }
        }
    }
}
