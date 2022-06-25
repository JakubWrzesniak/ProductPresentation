//
//  GameView.swift
//  ProductPresentation
//
//  Created by Jakub Wrześniak on 21/05/2022.
//

import Foundation
import SwiftUI

struct GameView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        //later
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let gameOn = GameViewController()
        return gameOn  
    }
}
