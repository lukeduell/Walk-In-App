//
//  FirebaseDetailViewModel.swift
//  CRMWalkinFirebase
//
//  Created by Skyler Duell on 8/25/23.
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
class FirebaseDetailViewModel: ObservableObject{
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    @Published var numItems: Int = 0
    @Published var listfinished: Bool = false
    @Published var listempty: Bool = false
    @Published var isLoading: Bool = false
    @Published var remoteStoragePath: String?
    @Published var downloadDone: Bool = false
    @Published var downloadedImage: [Image] = []
    @Published var errorFound: Bool = false
    @Published var errInfo: Error?
    @Published var fileLocalDownloadURL: URL?
    @Published var downloadedUIImage: [UIImage] = []
    @Published var downloadedData: [Data] = []
    
    
    enum escapeResult {
        case success, failure, empty
    }
    
    
    func update(userId: String, date: Date, firstandlast: String, phonenum: String, description: String, blast: String, prime: String, color: String, status: Bool, notes: String) -> Bool{
        let currentRef = db.collection("CustomerCollection").document(userId)
        
        currentRef.updateData([
            "date": date,
            "firstandlast": firstandlast,
            "phonenum": phonenum,
            "description": description,
            "blast": blast,
            "prime": prime,
            "color": color,
            "status": status,
            "notes": notes,
            "appupdated": "true"
        ]) { err in
            if let err = err{
                print("Error updating document \(err)")
            }
            else{
                print("Document Updated")
            }
        }
        return true
    }
    
    func listallDocuments(id: String, completion: @escaping (escapeResult) -> () ){
        let storageReference = storage.reference().child(id)
        storageReference.listAll { (result, error) in
            if let error = error {
                print(error)
                completion(.failure)
            }
            for item in result?.items ?? [] {
                print(item)
                self.numItems = self.numItems + 1
                if(self.numItems == result?.items.count){
                    completion(.success)
                }
            }
            if ((result?.items.isEmpty) != nil){
                completion(.empty)
            }
        }
    }
    
    func listall(id: String){
        listallDocuments(id: id) { result in
            switch result{
            case .success:
                //successfully found the number of images
                print("Number of images to load: \(self.numItems)")
                self.listfinished = true
                self.listempty = false
            case .failure:
                print("Failure")
                self.listfinished = false
                self.listempty = false
            case .empty:
                print("List empty")
                self.listfinished = false
                self.listempty = true
            }
        }
    }
    
    
    func setImage(fromImage image: UIImage) -> Image {
          return Image(uiImage: image)
    }
    func setImage(fromURL url: URL) -> Image {
        return setImage(fromImage: .init(contentsOfFile: url.path)!)
      }
    
    func downloadImage(id: String, count: Int, maxCount: Int) async {
      // Create a reference to the file you want to download
        remoteStoragePath = "\(id)/\(count).jpg"
        let storageRef = Storage.storage().reference()

        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL = documentsURL.appendingPathComponent("\(id)\(count).jpg")
        //guard let storagePath = remoteStoragePath else { return }
        let storagePath = "\(id)/\(count).jpg"

        isLoading = true
        do {
            //getting the image URL
            let imageURL = try await storageRef.child(storagePath).writeAsync(toFile: localURL)
            //converting the URL to a string
            let imageURLString = imageURL.absoluteString
            //checking to see if the count is max and done downloading images
            if((maxCount - 1) == count){
                downloadDone = true
            }
            if downloadedImage.count <= count{
                //saving as an image view
                downloadedImage.append(setImage(fromURL: imageURL))
                //saving as a data
                downloadedData.append(try Data(contentsOf: imageURL))
                //saving as UIImage
                downloadedUIImage.append(UIImage(data: downloadedData[count]) ?? UIImage())
            }
            else{
                //saving as an image view
                downloadedImage[count] = setImage(fromURL: imageURL)
                //saving as a data
                downloadedData[count] = try Data(contentsOf: imageURL)
                //saving as UIImage
                downloadedUIImage[count] = UIImage(data: downloadedData[count]) ?? UIImage()
            }
        } catch {
            errorFound = true
            errInfo = error
            print(error)
        }
        isLoading = false
    }    
}
