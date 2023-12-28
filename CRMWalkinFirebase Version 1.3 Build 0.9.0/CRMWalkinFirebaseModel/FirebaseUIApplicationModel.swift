//
//  FirebaseUIApplicationModel.swift
//  CRMWalkinFirebase
//
//  Created by Skyler Duell on 9/7/23.
//

import Foundation
import SwiftUI

extension UIApplication {
    
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
