//
//  FirebaseService.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/9/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

typealias FirDBCompletionHandler = (_ data: Any?, _ error: Error?) -> ()

struct FirebaseService {
   
   let dbRef = FIRDatabase.database().reference()
   
   /// Saves data to the database under the passed child node.
   /// An automatic id is generated for the entry.
   ///
   /// - Parameters:
   ///   - dictionary: The dictionary to be saved
   ///   - underChild: The child node where data will be saved
   func save(dictionary: Dictionary<String, Any>, underChild: String) {
      dbRef.child(underChild).childByAutoId().setValue(dictionary)
   }
   
   func save(dictionary: Dictionary<String, Any>, underChild: String, withId id: String) {
      dbRef.child(underChild).child(id).setValue(dictionary)
   }
   
   /// Reads all data from the database on the passed child node
   ///
   /// - Parameters:
   ///   - child: The child node to read data from
   ///   - onCompletion: The closure called when the request was processed.
   ///                   Has a data Any parameter and an error parameter.
   func readAll(from child: String, orderBy childKey: String? = nil, limit: UInt? = nil, endValue: Any? = nil, completion: @escaping FirDBCompletionHandler) {
      var query: FIRDatabaseQuery = dbRef.child(child)
      if let childKey = childKey {
         query = query.queryOrdered(byChild: childKey)
         if let endValue = endValue {
            query = query.queryEnding(atValue: endValue)
         }
         if let limit = limit {
            query = query.queryLimited(toLast: limit)
         }
      }
      
      query.observeSingleEvent(of: .value, with: { snapshot in
         completion(snapshot.value, nil)
      }) { error in
         completion(nil, error)
      }
   }
   
   func read(from child: String, id: String, onCompletion: @escaping FirDBCompletionHandler) {
      dbRef.child(child).child(id).observeSingleEvent(of: .value, with: { snapshot in
         onCompletion(snapshot.value, nil)
      }) { error in
         onCompletion(nil, error)
      }
   }
   
   func read(id: String, onCompletion: @escaping FirDBCompletionHandler) {
      dbRef.child(id).observeSingleEvent(of: .value, with: { snapshot in
         onCompletion(snapshot.value, nil)
      }) { error in
         onCompletion(nil, error)
      }
   }
   
   static func userFrom(_ user: FIRUser) -> User {
      let user = User(uid: user.uid)
      return user
   }
}
