//
//  AlertManager.swift
//  WakandaApp
//
//  Created by SOTSYS138 on 13/05/21.
//

import UIKit
import SwiftMessages

final class AlertManager {
    
    private init() {
    
    }
    
    static private var messageView: MessageView = {
        let messageView = MessageView.viewFromNib(layout: .cardView)
        messageView.configureDropShadow()
        messageView.button?.isHidden = true
        messageView.titleLabel?.font = UIFont(appFont: .PoppinsSemiBold, size: 17)
        messageView.bodyLabel?.font = UIFont(appFont: .PoppinsMedium, size: 13)
        return messageView
    }()
    
    static private var config: SwiftMessages.Config = {
        var config = SwiftMessages.Config()
        config.presentationStyle = .bottom
        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        config.duration = .seconds(seconds: 3.0)
        return config
    }()
    
    class func showSuccessAlert(title: String = "Success", message: String) {
        messageView.configureTheme(.success)
        messageView.configureContent(title: title, body: message)
        SwiftMessages.show(config: config, view: messageView)
    }
    
    class func showErrorAlert(title: String = "Error", message: String) {
        messageView.configureTheme(.error)
        messageView.configureContent(title: title, body: message)
        SwiftMessages.show(config: config, view: messageView)
    }
    
    class func showServiceErrorAlert(_ serviceError: ServiceError) {
        print(serviceError.localizedDescription)
        showErrorAlert(message: serviceError.localizedDescription)
    }
    
    class func showSyncErrorAlert(_ serviceError: ServiceError) {
        print(serviceError.localizedDescription)
        showErrorAlert(message: ServiceError(.somethingWentWrong).localizedDescription)
    }
    
    class func showNoInternetConnectionAlert() {
        showErrorAlert(title: "No Internet Connection!", message: "")
    }
    
    class func hideAlert() {
        SwiftMessages.hide()
    }
    
    class func systemAlert(title: String?, message: String?, positiveTitle: String, parentController: UIViewController, positiveActionHandler: @escaping () -> ()) {
        let alertVC = createAlertController(title: title, message: message)
        let positiveAction = UIAlertAction(title: positiveTitle, style: .default, handler: { _ in
            positiveActionHandler()
        })
        alertVC.addAction(positiveAction)
        parentController.present(alertVC, animated: true, completion: nil)
    }
    
    class func systemAlert(title: String?, message: String?, negativeTitle: String, positiveTitle: String, negativeActionHandler: @escaping () -> (), positiveActionHandler: @escaping () -> ()) {
        guard let topVC = UIApplication.shared.getTopMostViewController() else { return }
        systemAlert(title: title, message: message, negativeTitle: negativeTitle, positiveTitle: positiveTitle, parentController: topVC, negativeActionHandler: negativeActionHandler, positiveActionHandler: positiveActionHandler)
    }
    
    class func systemAlert(title: String?, message: String?, negativeTitle: String, positiveTitle: String, parentController: UIViewController, negativeActionHandler: @escaping () -> (), positiveActionHandler: @escaping () -> ()) {
        let alertVC = createAlertController(title: title, message: message)
        let negativeAction = UIAlertAction(title: negativeTitle, style: .default, handler: { action in
            negativeActionHandler()
        })
        let positiveAction = UIAlertAction(title: positiveTitle, style: .default, handler: { _ in
            positiveActionHandler()
        })
        alertVC.addAction(negativeAction)
        alertVC.addAction(positiveAction)
        parentController.present(alertVC, animated: true, completion: nil)
    }
    
    class func systemAlertWithTextField(title: String?, message: String?, textFieldPlaceholder: String, textFieldText: String, negativeTitle: String, positiveTitle: String, parentController: UIViewController, negativeActionHandler: @escaping () -> (), positiveActionHandler: @escaping (String) -> ()) {
        
        let alertVC = createAlertController(title: title, message: message)
        alertVC.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = textFieldPlaceholder
            if !textFieldText.isEmpty {
                textField.text = textFieldText
            }
        }
        let negativeAction = UIAlertAction(title: negativeTitle, style: .default, handler: { action in
            negativeActionHandler()
        })
        let positiveAction = UIAlertAction(title: positiveTitle, style: .default, handler: { _ in
            positiveActionHandler(alertVC.textFields?.first?.text ?? "")
        })
        alertVC.addAction(negativeAction)
        alertVC.addAction(positiveAction)
        parentController.present(alertVC, animated: true, completion: nil)
    }
    
    class private func createAlertController(title: String?, message: String?) -> UIAlertController {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.setTint(color: .appBlue)
        alertVC.setTitle(font: UIFont(appFont: .PoppinsMedium, size: 16), color: .black)
        alertVC.setMessage(font: UIFont(appFont: .PoppinsRegular, size: 15), color: .black)
        return alertVC
    }
}

extension UIAlertController {
    
    //Set background color of UIAlertController
    func setBackgroudColor(color: UIColor) {
        if let bgView = self.view.subviews.first,
           let groupView = bgView.subviews.first,
           let contentView = groupView.subviews.first {
            contentView.backgroundColor = color
        }
    }
    
    //Set title font and title color
    func setTitle(font: UIFont?, color: UIColor?) {
        guard let title = self.title else { return }
        let attributeString = NSMutableAttributedString(string: title)//1
        if let titleFont = font {
            attributeString.addAttributes([NSAttributedString.Key.font : titleFont],//2
                                          range: NSMakeRange(0, title.utf8.count))
        }
        if let titleColor = color {
            attributeString.addAttributes([NSAttributedString.Key.foregroundColor : titleColor],//3
                                          range: NSMakeRange(0, title.utf8.count))
        }
        self.setValue(attributeString, forKey: "attributedTitle")//4
    }
    
    //Set message font and message color
    func setMessage(font: UIFont?, color: UIColor?) {
        guard let title = self.message else {
            return
        }
        let attributedString = NSMutableAttributedString(string: title)
        if let titleFont = font {
            attributedString.addAttributes([NSAttributedString.Key.font : titleFont], range: NSMakeRange(0, title.utf8.count))
        }
        if let titleColor = color {
            attributedString.addAttributes([NSAttributedString.Key.foregroundColor : titleColor], range: NSMakeRange(0, title.utf8.count))
        }
        self.setValue(attributedString, forKey: "attributedMessage")//4
    }
    
    //Set tint color of UIAlertController
    func setTint(color: UIColor) {
        self.view.tintColor = color
    }
    
    func setSourceViewForIpad(_ sourceView: UIView?) {
        guard let sourceView = sourceView else { return }
        popoverPresentationController?.sourceView = sourceView
        popoverPresentationController?.sourceRect = CGRect(x: sourceView.bounds.midX, y: sourceView.bounds.midY, width: 0, height: 0)
    }
}
