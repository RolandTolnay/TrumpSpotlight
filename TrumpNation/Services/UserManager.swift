//
//  UserManager.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/10/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation
import Fabric
import Crashlytics

struct UserManager {
   
   static var userId: String?
   static var user: User?
   
   init() { }
   
   static func dictionary(from user: User) -> [String:Any] {
      var userDic = [String:Any]()
      userDic["uid"] = user.uid
      userDic["firstLogin"] = user.firstLoginSeconds
      userDic["trialStarted"] = user.trialStartedSeconds
      
      return userDic
   }
   
   func saveUser(_ user: User) {
      let userDictionary = UserManager.dictionary(from: user)
      FirebaseService().save(dictionary: userDictionary, underChild: "users", withId: user.uid)
   }
   
}

extension UserManager: UserTracker {
   
   static var isNewUser: Bool = true
   
   func didSignIn(user: User, completion: @escaping UserSignInCompletion) {
      UserManager.userId = user.uid
      authWithFabric(userId: user.uid)
      
      syncFromDB(user: user) { syncedUser in
         guard let syncedUser = syncedUser else {
            var savedUser = user
            self.saveNewUser(&savedUser)
            UserManager.user = savedUser
            completion(savedUser)
            return
         }
         
         UserManager.isNewUser = false
         UserManager.user = syncedUser
         completion(syncedUser)
      }
   }
   
   private func authWithFabric(userId: String) {
      Crashlytics.sharedInstance().setUserIdentifier(userId)
   }
   
   private func syncFromDB(user: User, completion: @escaping (_ user: User?)->()) {
      FirebaseService().read(from: "users", id: user.uid) { data, error in
         guard error == nil,
            let userDic = data as? [String:Any] else {
               completion(nil)
               return
         }
         var syncedUser = user
         syncedUser.firstLoginSeconds = userDic["firstLogin"] as? Int
         syncedUser.trialStartedSeconds = userDic["trialStarted"] as? Int
         
         completion(syncedUser)
      }
   }
   
   private func saveNewUser(_ user: inout User) {
      user.firstLoginSeconds = Date().seconds
      UserManager.isNewUser = true
      saveUser(user)
   }
}
