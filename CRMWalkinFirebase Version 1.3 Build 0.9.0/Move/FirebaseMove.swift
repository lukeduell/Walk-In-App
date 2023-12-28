//
//  FirebaseMove.swift
//  CRMWalkinFirebase
//
//  Created by Skyler Duell on 8/25/23.
//

import Foundation
import UIPilot

class FirebaseMove: ObservableObject {
    
    @Published var lastMoveVar: lastMove = .start
    enum lastMove{
        case start, signin, list, insert, loadadd, detail, loaddetail, loadupdate
    }
    
    let appPilot: UIPilot<AppRoute>

    init(pilot: UIPilot<AppRoute>) {
        self.appPilot = pilot
    }
    
    func pilotList(){
        appPilot.push(.List)
    }
    
    func pilotInsert(){
        appPilot.push(.Insert)
    }
    
    func pilotAddLoad(){
        appPilot.push(.LoadAdd)
    }
    
    func pilotDetail(){
        appPilot.push(.Detail)
    }
    
    func pilotLoadUpdate(){
        appPilot.push(.LoadUpdate)
    }
    
    func pilotDetailUpdate(){
        appPilot.push(.LoadDetail)
    }
    
    func pilotSignIn(){
        appPilot.push(.SignIn)
    }
    
    func pilotStart(){
        appPilot.push(.Start)
    }
    
    func rememberLastMove(move: AppRoute){
        switch(move){
        case .Start:
            lastMoveVar = .start
        case .SignIn:   
            lastMoveVar = .signin
        case .List:
            lastMoveVar = .list
        case .Insert:
            lastMoveVar = .insert
        case .LoadAdd:
            lastMoveVar = .loadadd
        case .Detail:
            lastMoveVar = .detail
        case .LoadDetail:
            lastMoveVar = .loaddetail
        case .LoadUpdate:
            lastMoveVar = .loadupdate
        }
    }
    func returnToLastMove(move: lastMove){
        switch(move){
        case .start:
            pilotSignIn()
        case .signin:
            pilotStart()
        case .list:
            pilotList()
        case .insert:
            pilotInsert()
        case .loadadd:
            pilotAddLoad()
        case .detail:
            pilotDetail()
        case .loaddetail:
            pilotDetailUpdate()
        case .loadupdate:
            pilotLoadUpdate()
        }
    }
}
