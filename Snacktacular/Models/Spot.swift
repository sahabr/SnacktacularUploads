//
//  Spot.swift
//  Snacktacular
//
//  Created by Brishti Saha on 4/4/21.
//

import Foundation
import Firebase
import MapKit

class Spot: NSObject, MKAnnotation {
    var name: String
    var address: String
    var coordinate: CLLocationCoordinate2D
    var averageRating: Double
    var numberOfReviews: Int
    var postingUserID: String
    var documentID: String
    
    var dictionary: [String: Any]{
        return ["name": name, "address": address, "latitude": latitude, "longitude": longitude,  "averageRating": averageRating, "numberOfReviews": numberOfReviews, "postingUserID": postingUserID ]
    }
    
    var latitude: CLLocationDegrees{
        return coordinate.latitude
    }
    
    var longitude: CLLocationDegrees{
        return coordinate.longitude
    }
    
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    var title: String? {
        return name
    }
    
    var subtitle: String? {
        return address
    }
    
    init(name: String, address: String, coordinate: CLLocationCoordinate2D,  averageRating: Double, numberOfReviews: Int, postingUserID: String, documentID: String){
        self.name = name
        self.address = address
        self.coordinate = coordinate
        self.averageRating = averageRating
        self.numberOfReviews = numberOfReviews
        self.postingUserID = postingUserID
        self.documentID = documentID
    }
    
    override convenience init(){
        self.init(name: "", address: "", coordinate: CLLocationCoordinate2D(),  averageRating: 0.0, numberOfReviews: 0, postingUserID: "", documentID: "")
    }
    
    convenience init(dictionary: [String: Any]){
        let name = dictionary["name"] as! String? ?? ""
        let address = dictionary["address"] as! String? ?? ""
        let latitude = dictionary["latitude"] as! Double? ?? 0.0
        let longitude = dictionary["longitude"] as! Double? ?? 0.0
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let averageRating = dictionary["averageRating"] as! Double? ?? 0.0
        let numberOfReviews = dictionary["numberOfReviews"] as! Int? ?? 0
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        //let documentID = dictionary["documentID"] as! String? ?? ""
        
        self.init(name: name, address: address, coordinate: coordinate, averageRating: averageRating, numberOfReviews: numberOfReviews, postingUserID: postingUserID, documentID: "")
    }
    
    func saveData(completion: @escaping (Bool)-> ()){
        let db = Firestore.firestore()
        guard let postingUserID = Auth.auth().currentUser?.uid else {
            print("ERROR: Could not save data because we don't have a valid postingUserID")
            return completion(false)
        }
        self.postingUserID = postingUserID
        
        let dataToSave: [String: Any] = self.dictionary
        
        if self.documentID == "" {
            var ref: DocumentReference? = nil
            ref = db.collection("spots").addDocument(data: dataToSave) { (error) in
                guard error == nil else{
                    print("Error: adding document \(error!.localizedDescription)")
                    return completion(false)
                }
                self.documentID = ref!.documentID
                print("Added document: \(self.documentID)")
                completion(true)
            }
        } else{
            let ref = db.collection("spots").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                guard error == nil else{
                    print("Error: updating document \(error!.localizedDescription)")
                    return completion(false)
                }
                print("Updated document: \(self.documentID)")
                completion(true)
            }
        }
    }
    
    func updateAverageRating(completed: @escaping() -> ()){
        let db = Firestore.firestore()
        let reviewsRef = db.collection("spots").document(documentID).collection("reviews")
        
        reviewsRef.getDocuments { (querySnapshot, error) in
            guard error == nil else {
                print("Error: failed to get query snapshot of reviews for reviewsRef \(reviewsRef)")
                return completed()
            }
            var ratingTotal = 0.0
            for document in querySnapshot!.documents {
                let reviewDictionary = document.data()
                let rating = reviewDictionary["rating"] as! Int? ?? 0
                ratingTotal = ratingTotal + Double(rating)
            }
            self.averageRating = ratingTotal
            self.numberOfReviews = querySnapshot?.count
            let dataToSave = self.dictionary
            let spotRef = db.collection("spots").document(self.documentID)
            spotRef.setData(dataToSave) { (error) in
                if let error = error {
                    print("Error: updating document \(self.documentID) after changing info \(error.localizedDescription)")
                    completed()
                }else {
                    print("New average \(self.averageRating) for \(self.documentID)")
                    completed()
                }
            }
        }
    }
}
