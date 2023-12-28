//
//  ContentView.swift
//  CRMWalkinFirebase
//
//  Created by Skyler Duell on 8/22/23.
//

import SwiftUI
import FirebaseEmailAuthUI
import UIKit
import Foundation
import FirebaseCore
import FirebaseFirestore
import UIPilot
import FirebaseStorage
import FirebaseDatabase
import UIPilot
import Photos
import PhotosUI

struct FirebaseDetailLoadingView: View {
    
    @ObservedObject var detailModel: FirebaseDetailViewModel
    @EnvironmentObject var networkMonitor: FirebaseNetworkMonitor
    @ObservedObject var moveModel: FirebaseMove
    @State var imageFailedPopup: Bool = false
    
    
    
    var body: some View {
        ZStack {
                if networkMonitor.isConnected{
                    VStack{
                        if(detailModel.listfinished){
                            ProgressView()
                                .onAppear(perform: {
                                    networkMonitor.numImages = detailModel.numItems
                                    //clearing all images from variables
                                    networkMonitor.imageTemp.removeAll()
                                    networkMonitor.imageData.removeAll()
                                    networkMonitor.image.removeAll()
                                    moveModel.pilotDetail()
                                })
                        }
                        else if(detailModel.listempty){
                            ProgressView()
                                .onAppear(perform: {
                                    networkMonitor.numImages = detailModel.numItems
                                    //clearing all images from variables
                                    networkMonitor.imageTemp.removeAll()
                                    networkMonitor.imageData.removeAll()
                                    networkMonitor.image.removeAll()
                                    moveModel.pilotDetail()
                                })
                        }
                        else{
                            ProgressView()
                                .task {
                                    detailModel.listall(id: networkMonitor.id)
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
}
