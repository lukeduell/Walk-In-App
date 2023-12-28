//
//  ContentView.swift
//  CRMWalkinFirebase
//
//  Created by Skyler Duell on 8/22/23.
//

import SwiftUI
import FirebaseEmailAuthUI
import UIKit


struct FirebaseInsertLoadingView: View {
    
    @ObservedObject var insertModel: FirebaseInsertViewModel
    @EnvironmentObject var networkMonitor: FirebaseNetworkMonitor
    @ObservedObject var moveModel: FirebaseMove
    
    let service: FirebaseListViewModel = FirebaseListViewModel()
    
    var body: some View {
        ZStack {
            if networkMonitor.isConnected{
                VStack{
                    Text("Upload in Progress...")
                    ProgressView()
                        .onAppear(perform: {
                            let addResult = insertModel.add(id: networkMonitor.id, date: networkMonitor.date, firstandlast: networkMonitor.firstandlast, phonenum: networkMonitor.phonenum, description: networkMonitor.description, blast: networkMonitor.blast, prime: networkMonitor.prime, color: networkMonitor.color, status: networkMonitor.status, notes: networkMonitor.notes, internalAuth: networkMonitor.authType, domain: networkMonitor.domain)

                            if(addResult){
                                Task{
                                    //refreshing the customer list after adding to it
                                    //refresh
                                    do{
                                        //getting both all customers and external customers for separate lists
                                        networkMonitor.extcustomers = try await service.getExtCustomers(domain: networkMonitor.domain)
                                        networkMonitor.customers = try await service.getCustomers()
                                        try await networkMonitor.imageResult = networkMonitor.uploadImageInsert(image: networkMonitor.image, id: networkMonitor.id)
                                    }catch{
                                        print(error)
                                    }
                                    //search for customers to find matching one
                                    //setting the recently set id to the network monitor id value
                                    networkMonitor.getId(Customer: networkMonitor.customers, firstandlast: networkMonitor.firstandlast)
                                    
                                    if (networkMonitor.imageResult){
                                        //move to next view
                                        moveModel.rememberLastMove(move: .List)
                                        moveModel.pilotList()
                                    }
                                }
                            }
                        })
                }
            }
            else{
                ZStack{
                    ProgressView{
                        VStack{
                            Text("No Network... ")
                        }
                        VStack{
                            Text("Attempting to Reconnect...")
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
