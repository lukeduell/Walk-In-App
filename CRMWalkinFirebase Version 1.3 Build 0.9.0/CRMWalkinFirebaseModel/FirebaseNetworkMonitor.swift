//
//  TaskNetworkMonitor.swift
//  CRMWalkin
//
//  Created by Skyler Duell on 8/10/23.
//

import Foundation
import Network
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseDatabase
import FirebaseStorage
import FirebaseCore
import FirebaseAuth
import FirebaseAuthUI
import FirebaseEmailAuthUI
import PhotosUI
import SwiftUI
import Photos

class FirebaseNetworkMonitor: ObservableObject{
    
    
    let store: Firestore = .firestore()
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "Monitor")
    var isConnected = false
    let storage = Storage.storage()


    

    //usiung to hold the values
    @Published var date: Date = Date()
    @Published var firstandlast: String = ""
    @Published var phonenum: String = ""
    @Published var description: String = ""
    @Published var blast: String = ""
    @Published var prime: String = ""
    @Published var color: String = ""
    @Published var status: Bool = false
    @Published var notes: String = ""
    @Published var appmade: String = ""
    @Published var searchresult: Bool = false
    @Published var id: String = ""
    @Published var numImages: Int?
    @Published var deleteTask: Bool = false
    @Published var deleteFinished: Bool = false

    
    @Published var customers: [Customers] = []
    @Published var extcustomers: [Customers] = []
    
    @Published var imageChanged_Updating: Bool = false
    
    @Published var username: String = ""
    @Published var signInError: Bool = false
    
    
    @Published var image: [UIImage] = []
    @Published var dataImage: Data = Data()
    @Published var imageChange: Bool = false
    @Published var imageTemp: [PhotosPickerItem] = []
    @Published var imageData: [Data] = []
    @Published var imageSize: Int?
    @Published var imageResult: Bool = false
    
    //auth settings for program
    @Published var authType: Bool = false
    @Published var domain: String = ""
    
    //sorting enum init
    @Published var sortOption: SortOption = .dateAZ
    
    
    @State private var count: Int = 0
    @Published var currentIdx: Int = 0
    @Published var customerReturn: Customers!
    
    enum SortOption {
        case nameAZ, dateAZ, dateZA, color, nameZA
    }
    
    init(){
        networkMonitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
            Task{
                await MainActor.run{
                    self.objectWillChange.send()
                }
            }
        }
        networkMonitor.start(queue: workerQueue)
    }
    
    
    func getDetail(Customer: [Customers], userId: String){
        for customer in Customer {
            if(customer.id == userId){
                blast = customer.blast ?? ""
                color = customer.color ?? ""
                date = customer.date ?? Date()
                description = customer.description ?? ""
                firstandlast = customer.firstandlast ?? ""
                id = customer.id!
                notes = customer.notes ?? ""
                phonenum = customer.phonenum ?? ""
                prime = customer.prime ?? ""
                status = customer.status ?? false
            }
        }
    }
    
    func getId(Customer: [Customers], firstandlast: String){
        for customer in Customer {
            if(customer.firstandlast == firstandlast){
                id = customer.id!
            }
        }
    }
    
    func sortCustomer(sortBy: SortOption, Customer: [Customers]) -> [Customers]{
        var customerReturn: [Customers] = []
        switch sortBy {
        case .nameAZ:
            customerReturn = Customer.sorted(by: {$0.firstandlast?.lowercased() ?? "NO NAME" < $1.firstandlast?.lowercased() ?? "NO NAME"})
        case .nameZA:
            customerReturn = Customer.sorted(by: {$0.firstandlast?.lowercased() ?? "NO NAME" > $1.firstandlast?.lowercased() ?? "NO NAME"})
        case .dateAZ:
            customerReturn = Customer.sorted(by: {$0.date ?? Date() < $1.date ?? Date()})
        case .dateZA:
            customerReturn = Customer.sorted(by: {$0.date ?? Date() > $1.date ?? Date()})
        case .color:
            customerReturn = Customer.sorted(by: {$0.color?.lowercased() ?? "NO COLOR" < $1.color?.lowercased() ?? "NO COLOR"})
        }
        return customerReturn
    }
    
    func deleteListIndex(at indexSet: IndexSet){
        //working with all data
        let userId = indexSet.map {self.customers[$0].id}.first
        if let userId = userId{
            store.collection("CustomerCollection").document(userId ?? "").delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
        //working with external customers data
        if(indexSet.count <= extcustomers.count){
            let extuserId = indexSet.map {self.extcustomers[$0].id}.first ?? ""
            if let extuserId = extuserId{
                store.collection("\(self.domain)CustomerCollection").document(extuserId ).delete() { err in
                    if let err = err {
                        print("Error removing external document: \(err)")
                    } else {
                        print("External document successfully removed!")
                    }
                }
            }
        }
    }
    
    func clearData(){
        id = ""
        blast = ""
        color = ""
        date = Date()
        description = ""
        firstandlast = ""
        notes = ""
        phonenum = ""
        prime = ""
        status = false
    }
    
    func deleteImagesLocal(imageCount: Int){
        for count in 0..<imageCount {
            //deleting all from local storage
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let localURL = documentsURL.appendingPathComponent("\(id)\(count).jpg")
            do{
                try FileManager.default.removeItem(at: localURL)
            }catch{
                print("Failed to delete from local file")
                print(error)
            }
        }
    }
    
    func deleteImagesFirebase(imageCount: Int){
        for count in 0..<imageCount {
            //deleting all from firebase storage
            let imageRef = Storage.storage().reference().child("\(id)").child("\(count).jpg")
            imageRef.delete(completion: { error in
                if let error = error{
                    print("File does not exist\(error)")
                    //error meaning the delete doesnt exist so move foreward
                }
                else{
                    print("Image Deleted")
                }
            })
        }
    }
    
    func deleteSingleImage(id: String, index: Int){
        //deleting single image from local storage
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL = documentsURL.appendingPathComponent("\(id)\(index).jpg")
        
        do{
            try FileManager.default.removeItem(at: localURL)
        }catch{
            print("Failed to delete from local file")
            print(error)
        }
        
        //deleting single imgae from firebase storage
        let imageRef = Storage.storage().reference().child("\(id)/\(index).jpg")
        imageRef.delete{ error in
            if let error = error{
                print("Failed to delete from firestore")
                print(error)
                //error meaning the delete doesnt exist so move foreward
            }
            else{
                print("Image Deleted")
            }
        }
    }
    func uploadImage(image: [UIImage], id: String) async throws-> Bool{
        let numImages = image.count
        for count in 0..<numImages{
            let storageRef = Storage.storage().reference().child("\(id)/\(count).jpg")
            let pngImage = image[count].pngData()
            _ = try await storageRef.putDataAsync(pngImage!)
        }
        self.deleteFinished = true
        return false
    }

    func uploadImageInsert(image: [UIImage], id: String) async throws-> Bool{
        let numImages = image.count
        for count in 0..<numImages{
            let storageRef = Storage.storage().reference().child("\(id)/\(count).jpg")
            let pngImage = image[count].pngData()
            _ = try await storageRef.putDataAsync(pngImage!)
        }
        return true
    }
    
    func uploadImageDetail(image: [UIImage], id: String, currentNumImages: Int) async throws-> Bool{
        let numImages = image.count
        for count in 0..<numImages{
            let numStoredImages = currentNumImages + count
            let storageRef = Storage.storage().reference().child("\(id)/\(numStoredImages).jpg")
            let pngImage = image[count].pngData()
            _ = try await storageRef.putDataAsync(pngImage!)
        }
        return true
    }
    
}
