//
//  ContentView.swift
//  CRMWalkinFirebase
//
//  Created by Skyler Duell on 8/22/23.
//

import SwiftUI
import FirebaseEmailAuthUI
import UIKit


@available(iOS 17.0, *)
struct FirebaseSignInView: View {
    
    @ObservedObject var viewModel: FirebaseSignInViewModel
    @ObservedObject var moveModel: FirebaseMove
    @EnvironmentObject var networkMonitor: FirebaseNetworkMonitor

    @State var signingIn: Bool = false
    
    @State private var intros: [FirebaseIntro] = sampleIntros
    @State private var activeIntro: FirebaseIntro?
    
    
    
    var body: some View {
        if(networkMonitor.isConnected){
            
            GeometryReader{
                let size = $0.size
                let safeArea = $0.safeAreaInsets
                
                VStack(spacing: 0){
                    if let activeIntro {
                        Rectangle()
                            .fill(activeIntro.bgColor)
                            .padding(.bottom, -30)
                            .overlay {
                                Circle()
                                    .fill(activeIntro.circleColor)
                                    .frame(width: 38, height: 38)
                                    .background(alignment: .leading, content: {
                                        Capsule()
                                            .fill(activeIntro.bgColor)
                                            .frame(width: size.width)
                                    })
                                    .background(alignment: .leading){
                                        Text(activeIntro.text)
                                            .font(.largeTitle)
                                            .foregroundStyle(activeIntro.textColor)
                                            .frame(width: textSize(activeIntro.text))
                                            .offset(x: 10)
                                            .offset(x: activeIntro.textOffset)
                                    }
                                    .offset(x: -activeIntro.circleOffset)
                            }
                    }
                    
                    //login button
                    LoginButtons()
                        .padding(.bottom, safeArea.bottom)
                        .padding(.top, 10)
                        .frame(maxWidth: .infinity)
                }
                .ignoresSafeArea()
            }
            .task {
                if activeIntro == nil {
                    activeIntro = sampleIntros.first
                    //delaying 0.15
                    let oneSecond = UInt64(1_000_000_000)
                    try? await Task.sleep(nanoseconds: oneSecond * UInt64(0.15))
                    animate(0)
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
            .navigationBarBackButtonHidden(true)
        }
    }
    func animate(_ index: Int, _ loop: Bool = true){
        if intros.indices.contains(index + 1){
            //Updating text
            activeIntro?.text = intros[index].text
            activeIntro?.textColor = intros[index].textColor
            
            //animating offsets
            withAnimation(.snappy(duration: 1), completionCriteria: .removed) {
                activeIntro?.textOffset = -(textSize(intros[index].text) + 20)
                activeIntro?.circleOffset = -(textSize(intros[index].text) + 20) / 2
            } completion: {
                //resetting offset
                withAnimation(.snappy(duration: 1), completionCriteria:
                        .logicallyComplete) {
                            activeIntro?.textOffset = 0
                            activeIntro?.circleOffset = 0
                            activeIntro?.circleColor = intros[index + 1].circleColor
                            activeIntro?.bgColor = intros[index + 1].bgColor
                        } completion: {
                            animate(index + 1, loop)
                        }
            }
        } else{
            //looping
            //resetting the index if looping
            if loop{
                animate(0, loop)
            }
        }
    }
    
    func textSize(_ text: String) -> CGFloat {
        return NSString(string: text).size(withAttributes: [.font: UIFont.preferredFont(forTextStyle: .largeTitle)]).width
    }
    @ViewBuilder
    func LoginButtons() -> some View{
        VStack{
            //MARK: - USERNAME INFORMATION
            HStack(spacing: 20) {
                TextField("Email", text: $networkMonitor.username)
                    .textContentType(.emailAddress)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 250)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)
                    .backgroundStyle(Color.gray)
            }
            VStack{
                Text(networkMonitor.signInError ? "Error Signing In (Invalid Password or Username or No Auth)" : "")
                    .foregroundStyle(.red)
            }
            .navigationBarBackButtonHidden(true)
            Button(action: {
                moveModel.rememberLastMove(move: .SignIn)
                moveModel.pilotSignIn()
            }) {
                Text("Sign In")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 30)
            }
            .disabled(networkMonitor.username.isEmpty)
            .background(networkMonitor.username.isEmpty ? .gray : .blue)
            .cornerRadius(.infinity)
        }
        .padding(50)
    }
}
