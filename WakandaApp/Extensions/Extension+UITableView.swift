//
//  Extension+UITableView.swift
//  WakandaApp
//
//  Created by SOTSYS138 on 03/05/21.
//

import UIKit

protocol TYTableViewCellReuseIdentifiable: TYIdentifiable { }
extension UITableViewCell: TYTableViewCellReuseIdentifiable { }
extension UITableViewHeaderFooterView: TYTableViewCellReuseIdentifiable { }

extension UITableView {
    
    func registerHeaderFooterCell<T: UITableViewHeaderFooterView>(_ type: T.Type, identifier: String = T.identifier) {
        self.register(type, forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    func dequequeCell<T: UITableViewCell>(identifier: String = T.identifier) -> T {
        return self.dequequeCell(identifier: identifier, for: nil)
    }
    
    func dequequeCell<T: UITableViewCell>(indexPath: IndexPath) -> T {
        return self.dequequeCell(identifier: T.identifier, for: indexPath)
    }
    
    func dequequeCell<T: UITableViewCell>(identifier: String, for indexPath: IndexPath?) -> T {
        guard let path = indexPath else {
            guard let cell = self.dequeueReusableCell(withIdentifier: identifier) as? T else {
                fatalError(self.execFailureMessage(identifier: identifier))
            }
            return cell
        }
        guard let cell = self.dequequeCell(identifier: identifier, for: path) as? T else {
            fatalError(self.execFailureMessage(identifier: identifier))
        }
        return cell
    }
    
    func dequeueHeaderFooterView<T: UITableViewHeaderFooterView>(identifier: String = T.identifier) -> T {
        guard let headerFooterView = dequeueReusableHeaderFooterView(withIdentifier: identifier) as? T else {
            fatalError(self.execFailureMessage(identifier: identifier))
        }
        return headerFooterView
    }
    
    func execFailureMessage(identifier: String) -> String {
        return "TY: Couldn't instantiate \(self) with identifier \(identifier), reuse-identifier of your cell must be same as your class name (check your storyboard or xib for reuse-identifier or check the reuse-identifier you register using [class or nib])"
    }
    
    func addRefreshControl(on vc: UIViewController, action: Selector, color: UIColor? = nil) {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = color ?? tintColor
        refreshControl.addTarget(vc, action: action, for: .valueChanged)
        addSubview(refreshControl)
    }
    
    func scrollToBottom() {
        let scrollPoint = CGPoint(x: 0, y: self.contentSize.height - self.frame.size.height)
        self.setContentOffset(scrollPoint, animated: true)
    }
}
