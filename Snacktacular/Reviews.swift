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
    
    
}
