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
import FirebaseFirestoreSwift
import Combine

struct Customers: Codable, Identifiable{
    @DocumentID var id: String?
    var blast: String?
    var color: String?
    var date: Date?
    var description: String?
    var firstandlast: String?
    var notes: String?
    var phonenum: String?
    var prime: String?
    var status: Bool?
}



class FirebaseListViewModel: ObservableObject{
    
    @EnvironmentObject var networkMonitor: FirebaseNetworkMonitor
    private let listMonitor = FirebaseNetworkMonitor()
    
    @Published var sortOption: SortOption = .dateZA
    enum SortOption {
        case nameAZ, dateAZ, dateZA, color, nameZA
    }
    
    let store: Firestore = .firestore()
    
    
    func getSortedCustomers(sortBy: SortOption) async -> [Customers]{
        var Customer: [Customers] = []
        var customerReturn: [Customers] = []
        
        do{
            Customer = try await getCustomers()
        }catch{
            print("Error getting customers")
        }
        
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
    
    //MARK: for CRM Customers
    func getCustomers() async throws -> [Customers]{
        let ANNOTATIONS_PATH = "CustomerCollection"
        return try await retrieve(path: ANNOTATIONS_PATH)
    }
    
    ///retrieves all the documents in the collection at the path
    private func retrieve<FC : Codable>(path: String) async throws -> [FC]{
        //Firebase provided async await.
        let querySnapshot = try await store.collection(path).getDocuments()
        return querySnapshot.documents.compactMap { document in
            do{
                return try document.data(as: FC.self)
            }catch{
                print(error)
                return nil
            }
        }
    }
    
    func getSortedExtCustomers(sortBy: SortOption, domain: String) async -> [Customers]{
        var extCustomer: [Customers] = []
        var extcustomerReturn: [Customers] = []
        
        do{
            extCustomer = try await getExtCustomers(domain: domain)
        }catch{
            print("Error getting customers")
        }
        
        switch sortBy {
        case .nameAZ:
            extcustomerReturn = extCustomer.sorted(by: {$0.firstandlast?.lowercased() ?? "NO NAME" < $1.firstandlast?.lowercased() ?? "NO NAME"})
        case .nameZA:
            extcustomerReturn = extCustomer.sorted(by: {$0.firstandlast?.lowercased() ?? "NO NAME" > $1.firstandlast?.lowercased() ?? "NO NAME"})
        case .dateAZ:
            extcustomerReturn = extCustomer.sorted(by: {$0.date ?? Date() < $1.date ?? Date()})
        case .dateZA:
            extcustomerReturn = extCustomer.sorted(by: {$0.date ?? Date() > $1.date ?? Date()})
        case .color:
            extcustomerReturn = extCustomer.sorted(by: {$0.color?.lowercased() ?? "NO COLOR" < $1.color?.lowercased() ?? "NO COLOR"})
        }
        return extcustomerReturn
        
    }
    
    //MARK: for EXTERNAL Customers
    func getExtCustomers(domain: String) async throws -> [Customers]{
        let ANNOTATIONS_PATH = domain + "CustomerCollection"
        return try await retrieve(path: ANNOTATIONS_PATH)
    }
    
    ///retrieves all the documents in the collection at the path
    private func retrieveExt<FC : Codable>(path: String) async throws -> [FC]{
        //Firebase provided async await.
        let querySnapshot = try await store.collection(path).getDocuments()
        return querySnapshot.documents.compactMap { document in
            do{
                return try document.data(as: FC.self)
            }catch{
                print(error)
                return nil
            }
        }
    }
}
