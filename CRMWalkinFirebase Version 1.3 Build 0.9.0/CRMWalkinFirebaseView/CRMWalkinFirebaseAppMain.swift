//
//  CRMWalkinFirebaseApp.swift
//  CRMWalkinFirebase
//
//  Created by Skyler Duell on 8/22/23.
//

import SwiftUI
import FirebaseCore
import FirebaseAuthUI
import FirebaseFirestore
import UIPilot

//MARK: - FIREBASE INIT
class AppDelegate: NSObject, UIApplicationDelegate, FUIAuthDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      let authUI = FUIAuth.defaultAuthUI()
      authUI?.delegate = self
      print("Firebase Configured")
    return true
  }
}

@available(iOS 17.0, *)
@main
struct CRMWalkinFirebaseAppMain: App {
    
    //register app delegate for firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var networkMonitor = FirebaseNetworkMonitor()
    @StateObject var listModel = FirebaseListViewModel()
    
    //uipilot init
    private let pilot: UIPilot<AppRoute>
    init() {
        pilot = .init(initial: .Start)
    }

    
    var body: some Scene {
        WindowGroup {
            UIPilotHost(pilot){ route in
                switch route {
                case .Start:
                    AnyView(
                        FirebaseSignInView(viewModel: FirebaseSignInViewModel(), moveModel: FirebaseMove(pilot: pilot))
                    )
                    .environmentObject(networkMonitor)
                case .Insert:
                    AnyView(
                        FirebaseInsertView(viewModel: FirebaseInsertViewModel(), moveModel: FirebaseMove(pilot: pilot))
                    )
                    .environmentObject(networkMonitor)
                case .List:
                    AnyView(
                        FirebaseListView(moveModel: FirebaseMove(pilot: pilot), detailModel: FirebaseDetailViewModel(), signModel: FirebaseSignInViewModel())
                    )
                    .environmentObject(networkMonitor)
                    .environmentObject(listModel)
                case .LoadAdd:
                    AnyView(
                        FirebaseInsertLoadingView(insertModel: FirebaseInsertViewModel(), moveModel: FirebaseMove(pilot: pilot))
                    )
                    .environmentObject(networkMonitor)
                case .Detail:
                    AnyView(
                        FirebaseDetailView(moveModel: FirebaseMove(pilot: pilot), detailModel: FirebaseDetailViewModel())
                    )
                    .environmentObject(networkMonitor)
                case .LoadUpdate:
                    AnyView(
                        FirebaseUpdatingView(detailModel: FirebaseDetailViewModel(), moveModel: FirebaseMove(pilot: pilot), insertModel: FirebaseInsertViewModel())
                    )
                    .environmentObject(networkMonitor)
                case .LoadDetail:
                    AnyView(
                        FirebaseDetailLoadingView(detailModel: FirebaseDetailViewModel(), moveModel: FirebaseMove(pilot: pilot))
                    )
                    .environmentObject(networkMonitor)
                case .SignIn:
                    AnyView(
                        FirebaseSignInLoadingView(viewModel: FirebaseSignInViewModel(), moveModel: FirebaseMove(pilot: pilot))
                    )
                    .environmentObject(networkMonitor)
                }
            }
            
        }
    }
}

enum AppRoute: Equatable {
    case Start
    case List
    case Insert
    case LoadAdd
    case Detail
    case LoadDetail
    case LoadUpdate
    case SignIn
}
