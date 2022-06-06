//
//  HalfSheetHelper.swift
//  AutoTask
//
//  Created by Justin Wong on 6/2/22.
//

import SwiftUI
import UIKit

struct HalfSheetHelper<SheetView: View>: UIViewControllerRepresentable {
    var sheetView: SheetView
    @Binding var showSheet: Bool
    
    let controller = UIViewController()
    
    func makeUIViewController(context: Context) -> UIViewController {
        controller.view.backgroundColor = .clear
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if showSheet {
            let sheetController = CustomHostingController(rootView: sheetView)
            uiViewController.present(sheetController, animated: true) {
                DispatchQueue.main.async {
                    self.showSheet.toggle()
                }
            }
        }
    }
}

class CustomHostingController<Content: View>: UIHostingController<Content> {
    override func viewDidLoad() {
        //setting presentation controller properties
        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium(), .large()]
            presentationController.selectedDetentIdentifier = .medium
            presentationController.prefersGrabberVisible = true
        }
    }
}
