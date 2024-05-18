//
//  CoordinatorPrototocol.swift
//  Pecode-Tasks-Test
//
//  Created by Oleg on 17.05.2024.
//

import UIKit

public protocol Coordinator: AnyObject {
    
    var navigationController: UINavigationController { get }
    
    func start()
    
}
