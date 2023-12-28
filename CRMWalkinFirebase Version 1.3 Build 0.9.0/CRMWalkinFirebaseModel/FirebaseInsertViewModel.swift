//
//  FirebaseDataStore.swift
//  CRMWalkinFirebase
//
//  Created by Skyler Duell on 8/23/23.
//
import SwiftUI
import Foundation
import FirebaseCore
import FirebaseFirestore
import UIPilot
import FirebaseStorage
import UIKit
import FirebaseDatabase

@MainActor
class FirebaseInsertViewModel: ObservableObject{
    
    
    let db = Firestore.firestore()
    let storage = Storage.storage()

    

    
    func add(id: String, date: Date, firstandlast: String, phonenum: String, description: String, blast: String, prime: String, color: String, status: Bool, notes: String, internalAuth: Bool, domain: String) -> Bool{
        
        let docData: [String: Any] = [
            "date": date,
            "firstandlast": firstandlast,
            "phonenum": phonenum,
            "description": description,
            "blast": blast,
            "prime": prime,
            "color": color,
            "status": status,
            "notes": notes,
            "appmade": "true"
        ]
        
        if(internalAuth){
            //adding data to strictly customer collection
            db.collection("CustomerCollection").document().setData(docData) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
        }
        else{
            //adding data to both customer collection and domain collection
            //customer collection
            db.collection("CustomerCollection").document().setData(docData) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
            //domain + collection
            db.collection(domain + "CustomerCollection").document().setData(docData) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
        }
        return true
    }
    
    func uploadImage(image: [UIImage], id: String) -> Bool{
        var numUploadImages = image.count
        for images in image{
            numUploadImages = numUploadImages - 1
            let imageRef = Storage.storage().reference().child("\(id)/\(numUploadImages).jpg")
            FirebaseInsertViewModel.uploadImage(images, at: imageRef) { (downloadURL) in
                guard let downloadURL = downloadURL else {
                    return
                }
                let urlString = downloadURL.absoluteString
                print("image url: \(urlString)")
            }
        }
        return true
    }
    
    
    static func uploadImage(_ image: UIImage, at reference: StorageReference, completion: @escaping (URL?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.1) else{
            return completion(nil)
        }
        reference.putData(imageData, metadata: nil, completion: {(metadata, error) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            reference.downloadURL(completion: { (url, error) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    return completion(nil)
                }
                completion(url)
            })
        })
    }
    
}
