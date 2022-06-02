//
//  KeyboardObserver.swift
//  WakandaApp
//
//  Created by SOTSYS138 on 03/06/21.
//

import UIKit

extension UIViewController {
    
    func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc internal func keyboardWillShow(_ notification: Notification) {
        adjustingHeight(true, notification: notification)
    }
    
    @objc internal func keyboardWillHide(_ notification: Notification) {
        adjustingHeight(false, notification: notification)
    }
    
    internal func adjustingHeight(_ show: Bool, notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let animationDurarion = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        changeKeyboardFrame(keyboardFrame, keyboardAnimationDuration: animationDurarion, isKeyboardShow: show)
    }
    
    @objc func changeKeyboardFrame(_ keyboardFrame: CGRect, keyboardAnimationDuration: TimeInterval, isKeyboardShow: Bool) {
    }
}
