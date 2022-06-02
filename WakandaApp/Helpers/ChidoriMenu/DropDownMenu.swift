//
//  DropDownMenu.swift
//  UpperTeams
//
//  Created by SOTSYS302 on 28/02/22.
//

import UIKit

typealias DropDownMenuDidSelect = (String) -> Void

class DropDownMenu: ChidoriDelegate, TYIdentifiable {
    
    private let menu: UIMenu!
    
    private var dropDownMenuDidSelect: DropDownMenuDidSelect?
    
    init(title: String = "", list: [String]) {
        var actions = [UIAction]()
        for row in list {
            let action = UIAction(title: row, identifier: UIAction.Identifier(row)) { ac in
            }
            actions.append(action)
        }
        self.menu = UIMenu(title: title, image: nil, identifier: nil, options: [.displayInline], children: actions)
    }
    
    func showMenu(on vc: UIViewController, summonView: UIView, topSpacing: CGFloat, completion: @escaping DropDownMenuDidSelect) {
        dropDownMenuDidSelect = completion
        
        ChidoriMenu.width = summonView.frame.width
        
        var summonPoint = summonView.globalFrame?.origin ?? .zero
        summonPoint.x = (vc.view.frame.width / 2) + 5
        summonPoint.y += topSpacing
        let chidoriMenu = ChidoriMenu(menu: menu, summonPoint: summonPoint)
        chidoriMenu.delegate = self
        vc.present(chidoriMenu, animated: true, completion: nil)
    }
    
    func didSelectAction(_ action: UIAction) {
        guard let dropDownMenuDidSelect = dropDownMenuDidSelect else { return }
        dropDownMenuDidSelect(action.title)
        self.dropDownMenuDidSelect = nil
    }
    
    deinit { print(identifier, "deinit") }
}
