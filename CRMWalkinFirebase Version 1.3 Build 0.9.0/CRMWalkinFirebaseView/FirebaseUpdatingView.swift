//
//  ContentView.swift
//  CRMWalkinFirebase
//
//  Created by Skyler Duell on 8/22/23.
//

import SwiftUI
import FirebaseEmailAuthUI
import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseCore

struct FirebaseUpdatingView: View {
    
    @ObservedObject var detailModel: FirebaseDetailViewModel
    @EnvironmentObject var networkMonitor: FirebaseNetworkMonitor
    @ObservedObject var moveModel: FirebaseMove
    @ObservedObject var insertModel: FirebaseInsertViewModel

    let service: FirebaseListViewModel = FirebaseListViewModel()
    let storage = Storage.storage()

    
    var body: some View {
        ZStack {
            if networkMonitor.isConnected{
                VStack{
                    Text("Update in Progress...")
                    ProgressView()
                        .onAppear(perform: {
                            let updateresult = detailModel.update(userId: networkMonitor.id, date: networkMonitor.date, firstandlast: networkMonitor.firstandlast, phonenum: networkMonitor.phonenum, description: networkMonitor.description, blast: networkMonitor.blast, prime: networkMonitor.prime, color: networkMonitor.color, status: networkMonitor.status, notes: networkMonitor.notes)
                            //deleting the image
                            if(networkMonitor.imageChanged_Updating){
                                let imageRef = Storage.storage().reference().child("\(networkMonitor.id).jpg")
                                imageRef.delete{ error in
                                    if let error = error{
                                        print(error)
                                        //error meaning the delete doesnt exist so move foreward
                                        if(updateresult){
                                            Task{
                                                //assign the customer id that was added to the photo
                                                //sending the array of images to upload image
                                                do{
                                                    try await networkMonitor.imageResult = networkMonitor.uploadImageDetail(image: networkMonitor.image, id: networkMonitor.id, currentNumImages: networkMonitor.numImages ?? 0)
                                                }
                                                catch{
                                                    print(error)
                                                }
                                                                                                
                                                if (networkMonitor.imageResult){
                                                    //move to next view
                                                    moveModel.rememberLastMove(move: .List)
                                                    moveModel.pilotList()
                                                }
                                            }
                                        }
                                    }
                                    else{
                                        if(updateresult){
                                            Task{
                                                //assign the customer id that was added to the photo
                                                //sending the array of images to upload image
                                                do{
                                                    try await networkMonitor.imageResult = networkMonitor.uploadImage(image: networkMonitor.image, id: networkMonitor.id)
                                                }
                                                catch{
                                                    print(error)
                                                }
                                                
                                                if (networkMonitor.imageResult){
                                                    //move to next view
                                                    moveModel.rememberLastMove(move: .List)
                                                    moveModel.pilotList()
                                                }
                                            }
                                        }
                                    }
                                }
                                networkMonitor.imageChanged_Updating = false
                            }
                            else{
                                moveModel.rememberLastMove(move: .List)
                                moveModel.pilotList()
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
