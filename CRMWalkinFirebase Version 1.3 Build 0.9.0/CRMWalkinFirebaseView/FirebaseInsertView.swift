//
//  ContentView.swift
//  CRMWalkinFirebase
//
//  Created by Skyler Duell on 8/22/23.
//

import SwiftUI
import FirebaseEmailAuthUI
import UIKit
import UIPilot
import PhotosUI


struct FirebaseInsertView: View {
    
    @ObservedObject var viewModel: FirebaseInsertViewModel
    @ObservedObject var moveModel: FirebaseMove
    @EnvironmentObject var networkMonitor: FirebaseNetworkMonitor
    @State private var showingAlertRemoveImage = false
    @State private var showingAlertUpdate = false

    var state = ["Yes", "No"]
    
    
    var body: some View {
        ZStack {
            if networkMonitor.isConnected{
                NavigationStack{
                    ScrollView{
                        Group{
                            
                            //date arrived section
                            dateView
                            
                            //first and last name section
                            firstandlastView
                            
                            //phone number section
                            phonenumView
                            
                            //description section
                            descriptionView
                            
                            //blast section
                            blastView
                            
                            //prime section
                            primeView
                            
                            //color section
                            colorView
                            
                        }
                        Group{
                            //notes section
                            notesView
                            
                            //status section
                            statusView
                            
                            //buttons section
                            buttonsView
                            
                            //image button
                            imageRemove
                        }
                    }
                }
                .navigationTitle(Text("Insert"))
                .toolbar{
                    ToolbarItem(placement: .navigationBarLeading){
                        //back button
                        Button(action: {
                            //clearing data
                            networkMonitor.imageData.removeAll()
                            //setting image chose to nil
                            networkMonitor.imageChange = false
                            //clearing image temp from the picker
                            networkMonitor.imageTemp.removeAll()
                            //moving to list
                            moveModel.rememberLastMove(move: .List)
                            moveModel.pilotList()
                        }) {
                            Text("Back")
                                .font(.headline)
                        }
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
        .navigationBarBackButtonHidden(true)
    }
    private var dateView: some View {
        HStack(spacing: 10) {
            Text("Date Arrived  :")
            DatePicker("", selection: $networkMonitor.date, displayedComponents: .date)
            
        }
        .padding()
    }
    private var firstandlastView: some View{
        HStack(spacing: 10) {
            Text("First and Last Name : ")
            TextField("First and Last Name", text: $networkMonitor.firstandlast)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
    }
    private var phonenumView: some View{
        HStack(spacing: 10) {
            Text("Phone Number : ")
            TextField("Phone Number", text: $networkMonitor.phonenum)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
            
        }
        .padding()
    }
    private var descriptionView: some View{
        HStack(spacing: 10) {
            Text("Description : ")
            TextField("Description", text: $networkMonitor.description)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
    }
    private var primeView: some View{
        HStack(spacing: 10) {
            Text("Blast : ")
            Picker("Blast", selection: $networkMonitor.blast){
                ForEach(state, id: \.self){
                    Text($0)
                }
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
    private var blastView: some View{
        HStack(spacing: 10) {
            Text("Prime : ")
            Picker("Prime", selection: $networkMonitor.prime){
                ForEach(state, id: \.self){
                    Text($0)
                }
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
    private var colorView: some View{
        HStack(spacing: 10) {
            Text("Color : ")
            TextField("Color", text: $networkMonitor.color)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
    }
    private var notesView: some View{
        HStack(spacing: 10) {
            Text("Notes : ")
            TextField("Notes", text: $networkMonitor.notes)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
    }
    private var statusView: some View{
        HStack{
            Text("Status : ")
            Picker("Status", selection: $networkMonitor.status){
                Text("In Process").tag(false)
                Text("Finished").tag(true)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
    private var buttonsView: some View{
        HStack(spacing: 10) {
            PhotosPicker(selection: $networkMonitor.imageTemp, matching: .images, label: {
                Text("Select Image")
                    .font(.caption)
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 25)
            })
            .background(.blue)
            .cornerRadius(.infinity)
            
            Spacer()
            
            Button(action: {
                showingAlertUpdate = true
            }) {
                Text("Add")
                    .foregroundColor(.white)
                    .font(.caption)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 25)
            }
            .background(.green)
            .cornerRadius(.infinity)
        }
        .confirmationDialog("Confirm Add", isPresented: $showingAlertUpdate){
            Button("Confirm Add", role: .destructive){
                moveModel.rememberLastMove(move: .LoadAdd)
                moveModel.pilotAddLoad()
            }
            Button("Cancel", role: .cancel){}
        }
        .frame(width: UIScreen.main.bounds.width / 1.5, alignment:
                .trailing)
        .onChange(of: networkMonitor.imageTemp) { items in
            //clearing out all selected items
            networkMonitor.imageData.removeAll()
            for items in items{
                Task{
                    if let datasecond = try await items.loadTransferable(type: Data.self){
                        //appending the data so it creates a new array index every time something is set to it
                        networkMonitor.imageData.append(datasecond)
                        networkMonitor.image.append(UIImage(data: datasecond) ?? UIImage())
                    }
                    networkMonitor.imageChange = true
                }
            }
        }
    }
    private var imageRemove: some View{
        HStack{
            Button(action: {
                showingAlertRemoveImage = true
            }) {
                Text("Remove Image")
                    .font(.caption)
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 25)
            }
            .background(.blue)
            .cornerRadius(.infinity)
            .disabled((!networkMonitor.imageChange) && ((networkMonitor.imageSize ?? 0) < 100000))
        }
        .confirmationDialog("Confirm Delete Image", isPresented: $showingAlertRemoveImage){
            Button("Confirm Delete", role: .destructive){
                networkMonitor.imageData.removeAll()
                //setting image chose to nil
                networkMonitor.imageChange = false
                //clearing image temp from the picker
                networkMonitor.imageTemp.removeAll()
            }
            Button("Cancel", role: .cancel){}
        }
        .padding(.vertical)
    }
}
