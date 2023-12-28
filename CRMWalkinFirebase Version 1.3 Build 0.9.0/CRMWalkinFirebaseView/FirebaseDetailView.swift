//
//  FirebaseDetailView.swift
//  CRMWalkinFirebase
//
//  Created by Skyler Duell on 8/25/23.
//

import SwiftUI
import FirebaseEmailAuthUI
import UIKit
import UIPilot
import Photos
import PhotosUI
import FirebaseStorage


struct FirebaseDetailView: View {
    
    @ObservedObject var moveModel: FirebaseMove
    @EnvironmentObject var networkMonitor: FirebaseNetworkMonitor
    @State private var customers: [Customers] = []
    @ObservedObject var detailModel: FirebaseDetailViewModel
    @State var imageTapped = false
    @State var imageTapped_ScrollView = false
    @State private var showingAlertRemoveImage = false
    @State private var showingAlertUpdate = false
    let storage = Storage.storage()
    
    
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
                            
                            //image section
                            imageView
                            
                            //image button
                            imageRemove
                        }
                    }
                }
                .navigationTitle(Text("Detail"))
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
                            //clearing image variable
                            networkMonitor.image.removeAll()
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
        .sheet(isPresented: $imageTapped){
            if(detailModel.downloadDone == true){
                if(networkMonitor.deleteTask){
                    Text("Deleting Image...")
                    ProgressView()
                        .onAppear(perform: {
                            deletingSingleImage
                        })
                }
                else{
                    if(networkMonitor.deleteFinished){
                        //when the delete is finished it will force it to close the sheet with scroll view
                        ProgressView()
                            .onAppear(perform: {
                                detailModel.listall(id: networkMonitor.id)
                                networkMonitor.numImages = detailModel.numItems
                                networkMonitor.deleteFinished = false
                                imageTapped = false
                            })
                    }
                    else{
                        imagescrollview
                    }
                    
                }
            }
            else{
                if((networkMonitor.numImages ?? 0) > 0 || detailModel.numItems > 0){
                    Text("Retrieving Images...")
                    ProgressView()
                }
                else{
                    Text("No Images to Display")
                    Button(action: {
                        self.imageTapped = false
                    }){
                        Text("Dismiss")
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
            PhotosPicker(selection: $networkMonitor.imageTemp, label: {
                Text("Select Image")
                    .font(.caption)
                    .foregroundColor(.white)
                    .font(.caption)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 15)
            })
            .background(.blue)
            .cornerRadius(.infinity)
            
            Spacer()
            
            //update button
            Button(action: {
                showingAlertUpdate = true
            }) {
                Text("Update")
                    .foregroundColor(.white)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 15)
                    .font(.caption)
            }
            .background(.green)
            .cornerRadius(.infinity)
            
        }
        .confirmationDialog("Confirm Update", isPresented: $showingAlertUpdate){
            Button("Confirm Update", role: .destructive){
                moveModel.rememberLastMove(move: .LoadUpdate)
                moveModel.pilotLoadUpdate()
            }
            Button("Cancel", role: .cancel){}
        }
        .frame(width: UIScreen.main.bounds.width / 1.5, alignment:
                .trailing)
        .onChange(of: networkMonitor.imageTemp) { items in
            networkMonitor.imageData.removeAll()
            for items in items{
                Task{
                    if let datasecond = try? await items.loadTransferable(type: Data.self){
                        networkMonitor.imageData.append(datasecond)
                        networkMonitor.image.append(UIImage(data: datasecond) ?? UIImage())
                    }
                    networkMonitor.imageChanged_Updating = true
                    //image was changed
                    networkMonitor.imageChange = true
                }
            }
        }
    }
    private var imageView: some View{
        HStack{
            //prompting the user to view the image(s)
            Button(action: {
                Task{
                    for count in 0..<(networkMonitor.numImages ?? 0){
                        await detailModel.downloadImage(id: networkMonitor.id, count: count, maxCount: networkMonitor.numImages ?? 0)
                    }
                }
                imageTapped = true
            }) {
                Text("View Image(s)")
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 25)
                    .font(.caption)
            }
            .background(.green)
            .cornerRadius(.infinity)
        }
    }
    private var imageRemove: some View{
        HStack{
            Button(action: {
                showingAlertRemoveImage = true
            }) {
                Text("Remove All Image(s)")
                    .font(.caption)
                    .foregroundColor(.white)
                    .font(.caption)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 15)
            }
            .background(.blue)
            .cornerRadius(.infinity)
        }
        .confirmationDialog("Confirm Remove Image(s)", isPresented: $showingAlertRemoveImage){
            Button("Confirm Delete All Images", role: .destructive){
                //deleting all from local and firebase
                detailModel.numItems = networkMonitor.numImages ?? 0
                networkMonitor.deleteImagesFirebase(imageCount: detailModel.numItems)
                networkMonitor.deleteImagesLocal(imageCount: detailModel.numItems)
                //emptying variables
                detailModel.downloadedImage.removeAll()
                //setting image chose to nil
                networkMonitor.imageChange = false
            }
            Button("Cancel", role: .cancel){}
        }
        .padding(.vertical)
    }
    private var deletingSingleImage: Void{
        detailModel.downloadedData.remove(at: networkMonitor.currentIdx)
        detailModel.downloadedImage.remove(at: networkMonitor.currentIdx)
        detailModel.downloadedUIImage.remove(at: networkMonitor.currentIdx)
        //removing the image on the database and local
        networkMonitor.deleteImagesLocal(imageCount: detailModel.numItems)
        networkMonitor.deleteImagesFirebase(imageCount: detailModel.numItems)
        //need to reupload images to change names of images
        Task{
            do{
                try await networkMonitor.deleteTask = networkMonitor.uploadImage(image: detailModel.downloadedUIImage, id: networkMonitor.id)
            }
            catch{
                print("Error uploading")
            }
        }
    }
    
    private var imagescrollview: some View{
        //if there is no deletion, the scroll view will stay
        
        ScrollView{
            if(detailModel.downloadedImage.count > 0){
                VStack(spacing: 20){
                    HStack{
                        Button(action: {
                            self.imageTapped = false
                        }){
                            Text("Dismiss")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical)
                    
                    VStack{
                        ForEach(0..<(detailModel.downloadedImage.count)){ imageIdx in
                            detailModel.downloadedImage[imageIdx]
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .onTapGesture {
                                    //confirmation dialog to confirm delete of image. need id with number associated with image
                                    networkMonitor.currentIdx = imageIdx
                                    imageTapped_ScrollView = true
                                }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            else{
                Text("No Images to Display")
            }
        }
        .confirmationDialog("Confirm Delete", isPresented: $imageTapped_ScrollView){
            Button("Confirm Picture Delete", role: .destructive){
                networkMonitor.deleteTask = true
                imageTapped_ScrollView = false
            }
            Button("Cancel", role: .cancel){
                imageTapped_ScrollView = false
            }
        }
    }
}
