//
//  LaunchController.swift
//  WakandaApp
//
//  Created by SOTSYS302 on 30/03/22.
//

import UIKit

class LaunchController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigateToCameraVC()
    }
    
    private func navigateToCameraVC() {
        let cameraVC: CameraController = UIStoryboard(.main).instantiateVC()
        navigationController?.setViewControllers([cameraVC], animated: false)
    }
    
    deinit { print(identifier, "deinit") }
}
