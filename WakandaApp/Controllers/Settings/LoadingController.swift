//
//  LoadingController.swift
//  WakandaApp
//
//  Created by SOTSYS138 on 13/05/21.
//

import UIKit
import Lottie

enum LoadingType: String {
    case loading = "LoadingAnimation"
}

class LoadingController: UIViewController {
    
    @IBOutlet weak var lottieView: AnimationView!
    
    private static var window: UIWindow?
    
    static var loadingVC: LoadingController = {
        let loadingVC: LoadingController = UIStoryboard(.settings).instantiateVC()
        return loadingVC
    }()
    
    static func loadController() {
        let _ = loadingVC.view
        loadingVC.lottieView.animation = Animation.named(LoadingType.loading.rawValue)
        loadingVC.lottieView.contentMode = .scaleAspectFit
        loadingVC.lottieView.loopMode = .loop
    }
    
    static func presentLoader(loadingType: LoadingType = .loading) {
        guard let windowScene = UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive }).first as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        window?.frame = UIScreen.main.bounds
        window?.backgroundColor = .clear
        window?.windowLevel = UIWindow.Level.normal
        window?.rootViewController = loadingVC
        window?.makeKeyAndVisible()
        
        loadingVC.lottieView.animation = Animation.named(loadingType.rawValue)
        loadingVC.lottieView.play()
    }
    
    static func finishAndDismissLoader(completion: @escaping () -> ()) {
        loadingVC.lottieView.play(fromProgress: loadingVC.lottieView.currentProgress, toProgress: 1, loopMode: .playOnce) { completed in
            dismissLoader()
            completion()
        }
    }
    
    static func dismissLoader() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else { return }
        sceneDelegate.window?.makeKeyAndVisible()
        window?.windowScene = nil
        window = nil
        
        loadingVC.lottieView.pause()
    }
    
    deinit { print(identifier, "deinit") }
}
