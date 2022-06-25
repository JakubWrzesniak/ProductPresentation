//
//  HalfSheet.swift
//  ProductPresentation
//
//  Created by Jakub Wrześniak on 21/05/2022.
//

import Foundation
import SwiftUI

extension View{
    func halfSheet<SheetView: View>(showSheet: Binding<Bool>, @ViewBuilder sheetView: @escaping () -> SheetView) -> some View{
        return self
            .background{
                HalfSheetHelper(sheetView: sheetView(), showSheet: showSheet)
            }
    }
}

struct HalfSheetHelper<SheetView: View>: UIViewControllerRepresentable {
    var sheetView: SheetView
    
    @Binding var showSheet: Bool
    
    let controller = UIViewController()
    func makeUIViewController(context: Context) -> UIViewController {
        controller.view.backgroundColor = .clear
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if showSheet{
            
            let sheetController = CustomeHostingController(rootView: sheetView)
            
            uiViewController.present(sheetController, animated: true) {
                DispatchQueue.main.async {
                    self.showSheet.toggle()
                }
            }
        }
    }
}

class CustomeHostingController<Content: View>: UIHostingController<Content>{
    override func viewDidLoad() {
        if let presentatioNController = presentationController as? UISheetPresentationController {
            presentatioNController.detents = [
                .medium(),
                .large()
            ]
            
            presentatioNController.prefersGrabberVisible = true
            presentatioNController.preferredCornerRadius = 10.0
        }
    }
}
