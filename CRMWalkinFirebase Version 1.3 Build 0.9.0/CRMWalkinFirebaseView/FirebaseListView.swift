//
//  FirebaseListView.swift
//  CRMWalkinFirebase
//
//  Created by Skyler Duell on 8/24/23.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import UIKit

struct FirebaseListView: View {
    
    @ObservedObject var moveModel: FirebaseMove
    @EnvironmentObject var networkMonitor: FirebaseNetworkMonitor
    @ObservedObject var detailModel: FirebaseDetailViewModel
    @EnvironmentObject var listModel: FirebaseListViewModel
    @ObservedObject var signModel: FirebaseSignInViewModel
    
    
    @State var showAction: Bool = false
    @State var presentingAction: Bool = false
    @State var sortingName: Bool = false
    @State var sortingNameImage: Bool = false
    @State var sortingDate: Bool = false
    @State var sortingDateImage: Bool = false
    @State private var showingAlert = false
    @State private var deleteIndexSet: IndexSet?
    
    //binding string
    @State private var searchText = ""
    
    let service: FirebaseListViewModel = FirebaseListViewModel()
    
    var body: some View{
        ZStack {
            if networkMonitor.isConnected{
                //MARK: - Internal Customers
                if(networkMonitor.authType){
                    NavigationStack{
                        if networkMonitor.customers.isEmpty {
                            VStack{
                                Text("No Data")
                                    .task{
                                        do{
                                            networkMonitor.customers = await service.getSortedCustomers(sortBy: .dateZA)
                                        }
                                    }
                            }
                            .navigationTitle(Text("CRM Walkin Work"))
                        }else {
                            VStack{
                                sorting
                                    .padding()
                                allCustomersList
                            }
                            .navigationTitle(Text("CRM Walkin Work"))
                        }
                    }
                    .searchable(text: $searchText)
                    .onAppear(perform: {
                        Task{
                            //refreshing the data on move to view
                            networkMonitor.customers = await service.getSortedCustomers(sortBy: .dateZA)
                        }
                    })
                    
                }
                //MARK: - External Customers
                else{
                    NavigationStack{
                        if networkMonitor.extcustomers.isEmpty {
                            VStack{
                                Text("No Data")
                                    .task{
                                        do{
                                            //fix this for sorting on appear
                                            networkMonitor.extcustomers = await service.getSortedExtCustomers(sortBy: .dateZA, domain: networkMonitor.domain)
                                        }
                                    }
                            }
                            .navigationTitle(Text("CRM Walkin Work"))
                        }else {
                            VStack{
                                extsorting
                                    .padding()
                                extallCustomersList
                            }
                            .navigationTitle(Text("CRM Walkin Work"))
                        }
                    }
                    .searchable(text: $searchText)
                    .onAppear(perform: {
                        Task{
                            //refreshing the data on move to view
                            //fix this for sorting on appear
                            networkMonitor.extcustomers = await service.getSortedExtCustomers(sortBy: .dateZA, domain: networkMonitor.domain)
                        }
                    })
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        signOutButton
                        Spacer()
                        Spacer()
                        plusButton
                        Spacer()
                    }
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
        .refreshable {
            Task{
                if(networkMonitor.authType){
                    //remember the sorting type when refreshing
                    networkMonitor.customers = await service.getSortedCustomers(sortBy: listModel.sortOption)
                }
                else{
                    //remember the sorting type when refreshing
                    networkMonitor.extcustomers = await service.getSortedExtCustomers(sortBy: listModel.sortOption, domain: networkMonitor.domain)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    
    var searchResults: [Customers] {
        if searchText.isEmpty{
            return networkMonitor.customers
        } else{
            return networkMonitor.customers.filter { Customers in
                Customers.firstandlast?.lowercased().contains(searchText.lowercased()) ?? false || Customers.description?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
    }
    
    
    //MARK: FUNCTIONS FOR VIEWS
    private var allCustomersList: some View {
        List{
            ForEach(searchResults, id: \.id){ task in
                HStack{
                    Text("\(task.date?.formatted(date: .abbreviated, time: .omitted) ?? "NO DATE" )")
                        .padding(.horizontal, 20)
                    Text("\(task.firstandlast ?? "NO NAME")")
                    Spacer()
                    Text("\(task.description ?? "")")
                }
                .font(.headline)
                .onTapGesture {
                    networkMonitor.id = task.id ?? ""
                    networkMonitor.getDetail(Customer: networkMonitor.customers, userId: networkMonitor.id)
                    //detail loading
                    moveModel.rememberLastMove(move: .LoadDetail)
                    moveModel.pilotDetailUpdate()
                }
                .disabled(!(networkMonitor.authType))
            }
            .onDelete(perform: { indexSet in
                self.deleteIndexSet = indexSet
                self.showingAlert = true
            })
            .confirmationDialog("Confirm Delete", isPresented: $showingAlert){
                Button("Confirm", role: .destructive){
                    networkMonitor.deleteListIndex(at: deleteIndexSet ?? IndexSet())
                    detailModel.listall(id: networkMonitor.id)
                    networkMonitor.deleteImagesFirebase(imageCount: detailModel.numItems)
                    moveModel.pilotList()
                }
                Button("Cancel", role: .cancel){}
            }
            .deleteDisabled(!(networkMonitor.authType))
        }
        .listStyle(PlainListStyle())
        .task {
            do{
                networkMonitor.customers = await service.getSortedCustomers(sortBy: listModel.sortOption)
            }
        }
    }
    private var sorting: some View {
        HStack{
            //SORTING BEFORE THE LIST
            //DATE
            HStack{
                Text("Date")
                Image(systemName: "chevron.down")
                    .opacity(sortingDateImage ? 1.0: 0.0)
                    .rotationEffect(Angle(degrees: sortingDate ? 0 : 180))
            }
            .onTapGesture(perform: {
                
                sortingDate = !sortingDate
                sortingDateImage = true
                if(sortingDate){
                    networkMonitor.customers = networkMonitor.sortCustomer(sortBy: .dateAZ, Customer: networkMonitor.customers)
                    listModel.sortOption = .dateAZ
                    sortingNameImage = false
                }
                else{
                    networkMonitor.customers = networkMonitor.sortCustomer(sortBy: .dateZA, Customer: networkMonitor.customers)
                    listModel.sortOption = .dateZA
                    sortingNameImage = false
                }
            })
            
            Spacer()
            //NAME
            HStack(){
                Text("Name")
                Image(systemName: "chevron.down")
                    .opacity(sortingNameImage ? 1.0: 0.0)
                    .rotationEffect(Angle(degrees: sortingName ? 0 : 180))
            }
            .onTapGesture(perform: {
                
                sortingName = !sortingName
                sortingNameImage = true
                if(sortingName){
                    networkMonitor.customers = networkMonitor.sortCustomer(sortBy: .nameAZ, Customer: networkMonitor.customers)
                    listModel.sortOption = .nameAZ
                    sortingDateImage = false
                }
                else{
                    networkMonitor.customers = networkMonitor.sortCustomer(sortBy: .nameZA, Customer: networkMonitor.customers)
                    listModel.sortOption = .nameZA
                    sortingDateImage = false
                }
                
            })
            Spacer()
            HStack{
                Text("Desctiption")
            }
        }
        .font(.caption)
        .foregroundColor(Color.gray)
        .frame(width: UIScreen.main.bounds.width / 1.3, alignment:
                .trailing)
    }
    
    var extsearchResults: [Customers] {
        if searchText.isEmpty{
            return networkMonitor.extcustomers
        } else{
            return networkMonitor.extcustomers.filter { Customers in
                Customers.firstandlast?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
    }
    
    
    //MARK: FUNCTIONS FOR VIEWS
    private var extallCustomersList: some View {
        List{
            ForEach(extsearchResults, id: \.id){ task in
                HStack{
                    Text("\(task.date?.formatted(date: .abbreviated, time: .omitted) ?? "NO DATE" )")
                    Spacer()
                    Text("\(task.firstandlast ?? "NO NAME")")
                }
                .font(.headline)
                .onTapGesture {
                    networkMonitor.id = task.id ?? ""
                    networkMonitor.getDetail(Customer: networkMonitor.extcustomers, userId: networkMonitor.id)
                    //detail loading
                    moveModel.rememberLastMove(move: .LoadUpdate)
                    moveModel.pilotDetailUpdate()
                }
                .disabled(!(networkMonitor.authType))
                .padding(.horizontal)
            }
            .onDelete(perform: networkMonitor.deleteListIndex(at:))
            .deleteDisabled(!(networkMonitor.authType))
        }
        .listStyle(PlainListStyle())
        .task {
            do{
                networkMonitor.extcustomers = try await service.getExtCustomers(domain: networkMonitor.domain)
            }catch{
                print(error)
            }
        }
    }
    private var extsorting: some View {
        HStack{
            //SORTING BEFORE THE LIST
            //DATE
            HStack{
                Text("Date")
                Image(systemName: "chevron.down")
                    .opacity(sortingDateImage ? 1.0: 0.0)
                    .rotationEffect(Angle(degrees: sortingDate ? 0 : 180))
            }
            .onTapGesture(perform: {
                
                sortingDate = !sortingDate
                sortingDateImage = true
                if(sortingDate){
                    networkMonitor.extcustomers = networkMonitor.sortCustomer(sortBy: .dateAZ, Customer: networkMonitor.extcustomers)
                    sortingNameImage = false
                }
                else{
                    networkMonitor.extcustomers = networkMonitor.sortCustomer(sortBy: .dateZA, Customer: networkMonitor.extcustomers)
                    sortingNameImage = false
                }
            })
            Spacer()
            //NAME
            HStack(spacing: 20){
                Text("Name")
                Image(systemName: "chevron.down")
                    .opacity(sortingNameImage ? 1.0: 0.0)
                    .rotationEffect(Angle(degrees: sortingName ? 0 : 180))
            }
            .onTapGesture(perform: {
                
                sortingName = !sortingName
                sortingNameImage = true
                if(sortingName){
                    networkMonitor.extcustomers = networkMonitor.sortCustomer(sortBy: .nameAZ, Customer: networkMonitor.extcustomers)
                    sortingDateImage = false
                }
                else{
                    networkMonitor.extcustomers = networkMonitor.sortCustomer(sortBy: .nameZA, Customer: networkMonitor.extcustomers)
                    sortingDateImage = false
                }
                
            })
        }
        .font(.caption)
        .foregroundColor(Color.gray)
        .padding(.horizontal)
        .frame(width: UIScreen.main.bounds.width / 1.5, alignment:
                .trailing)
    }
    
    
    private var signOutButton: some View {
        //MARK: - SIGN OUT BUTTON
        Button(action: {
            signModel.signOut()
            networkMonitor.signInError = false
            moveModel.rememberLastMove(move: .Start)
            moveModel.pilotStart()
        }) {
            Text("Sign Out")
                .foregroundColor(.white)
                .font(.headline)
                .padding(.vertical, 10)
                .padding(.horizontal, 30)
        }
        .background(.blue)
        .cornerRadius(.infinity)
        
    }
    
    private var plusButton: some View {
        //MARK: - PLUS BUTTON
        Button(action: {
            networkMonitor.clearData()
            moveModel.pilotInsert()
            moveModel.rememberLastMove(move: .Insert)
        }) {
            Image(systemName: "plus")
                .resizable()
                .scaledToFill()
                .frame(width: 25, height: 25, alignment: .bottom)
                .foregroundColor(.white)
                .padding(20)
        }
        .background(.blue)
        .cornerRadius(.infinity)
    }
}
