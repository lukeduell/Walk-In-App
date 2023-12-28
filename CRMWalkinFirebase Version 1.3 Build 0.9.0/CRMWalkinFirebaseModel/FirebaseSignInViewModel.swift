//
//  FirebaseSignIn.swift
//  CRMWalkinFirebase
//
//  Created by Skyler Duell on 8/22/23.
//

import Foundation
import FirebaseAuth
import FirebaseAuthUI
import FirebaseEmailAuthUI
import SwiftUI

class FirebaseSignInViewModel: ObservableObject {
    
    @Published var username: String = ""
    @Published var password: String = ""
    let authResult = ""
    
    @Published var signInResult: Int = 0
    

    
    func checkUserAuth(email: String) -> Bool{
        let atSymbol = "@"
        if(email.contains(atSymbol)){
            let domain = email.components(separatedBy: atSymbol)
            if(domain[1] == "crminctc.com"){
                return true
            }
            else{
                return false
            }
        }
        else{
            return false
        }
        
    }
    func getDomain(email: String) -> String{
        let atSymbol = "@"
        if(email.contains(atSymbol)){
            let domain = email.components(separatedBy: atSymbol)
            if(domain[1] == "crminctc.com"){
                return domain[1]
            }
            else{
                return domain[1]
            }
        }
        else{
            return ""
        }
        
    }
    
    func signIn(email: String){
        Auth.auth().signIn(withEmail: email, password: "Crminctc495") {(auth, error) in
            if let maybeError = error { //if there was an error, handle it
                let err = maybeError as NSError
                switch err.code {
                case AuthErrorCode.wrongPassword.rawValue:
                    print("wrong password")
                    self.signInResult = 1
                case AuthErrorCode.invalidEmail.rawValue:
                    print("invalid email")
                    self.signInResult = 1
                default:
                    print("unknown error: \(err.localizedDescription)")
                    self.signInResult = 2
                }
            } else { //there was no error so the user could be auth'd or maybe not!
                if let _ = auth?.user {
                    print("User Is Auth")
                    self.signInResult = 4
                } else {
                    print("No User Auth")
                    self.signInResult = 3
                }
            }
        }
    }
    func signOut(){
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
}
