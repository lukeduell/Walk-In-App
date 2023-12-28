//
//  FirebaseIntro.swift
//  CRMWalkinFirebase
//
//  Created by Skyler Duell on 9/22/23.
//

import Foundation
import SwiftUI

struct FirebaseIntro: Identifiable{
    var id: UUID = .init()
    var text: String = ""
    var textColor: Color
    var circleColor: Color
    var bgColor: Color
    var circleOffset: CGFloat = 0
    var textOffset: CGFloat = 0
}

var sampleIntros: [FirebaseIntro] = [
    .init(
        text: "Welcome",
        textColor: .color1,
        circleColor: .color1,
        bgColor: .color4
    ),
    .init(
        text: "High Quality Coatings",
        textColor: .color4,
        circleColor: .color4,
        bgColor: .color1
    ),
    .init(
        text: "CRM Advantage",
        textColor: .color2,
        circleColor: .color2,
        bgColor: .color5
    ),
    .init(
        text: "CRM's Walk-In App",
        textColor: .color5,
        circleColor: .color5,
        bgColor: .color2
    ),
    .init(
        text: "Sign In Below",
        textColor: .color3,
        circleColor: .color3,
        bgColor: .color6
    ),
    .init(
        text: "",
        textColor: .color1,
        circleColor: .color1,
        bgColor: .color4
    ),
]
