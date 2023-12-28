//
//  ContentView.swift
//  CRMWalkinFirebase
//
//  Created by Skyler Duell on 8/22/23.
//

import SwiftUI
import FirebaseEmailAuthUI
import UIKit


struct FirebaseSignInLoadingView: View {
    
    @ObservedObject var viewModel: FirebaseSignInViewModel
    @EnvironmentObject var networkMonitor: FirebaseNetworkMonitor
    @ObservedObject var moveModel: FirebaseMove
    
    let service: FirebaseListViewModel = FirebaseListViewModel()
    
    var body: some View {
        ZStack {
            if networkMonitor.isConnected{
                VStack{
                    if viewModel.signInResult == 0{
                        ProgressView()
                            .onAppear(perform: {
                                networkMonitor.authType = viewModel.checkUserAuth(email: networkMonitor.username)
                                networkMonitor.domain = viewModel.getDomain(email: networkMonitor.username)
                                viewModel.signIn(email: networkMonitor.username)
                            })
                    }
                    else{
                        ProgressView()
                            .task {
                                if(viewModel.signInResult == 4){
                                    //moving to next view
                                    moveModel.rememberLastMove(move: .List)
                                    moveModel.pilotList()
                                }
                                else if(viewModel.signInResult == 3){
                                    networkMonitor.signInError = true
                                    moveModel.rememberLastMove(move: .Start)
                                    moveModel.pilotStart()
                                }
                                else if(viewModel.signInResult == 2){
                                    networkMonitor.signInError = true
                                    moveModel.rememberLastMove(move: .Start)
                                    moveModel.pilotStart()
                                }
                                else if(viewModel.signInResult == 1){
                                    networkMonitor.signInError = true
                                    moveModel.rememberLastMove(move: .Start)
                                    moveModel.pilotStart()
                                }
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
