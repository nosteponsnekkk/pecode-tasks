//
//  MainCoordinator.swift
//  Pecode-Tasks-Test
//
//  Created by Oleg on 17.05.2024.
//

import UIKit

public final class MainCoordinator: Coordinator {
    
    //MARK: - Basic
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public var navigationController: UINavigationController
    private var viewModel = TaskViewModel()
    
    public func start() {
        let vc = HomeViewController(viewModel: viewModel)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    
}
//MARK: - Transitions
extension MainCoordinator {
    public func createTask(){
        let vc = CreateTaskViewController(viewModel: viewModel)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    public func editTask(at indexPath: IndexPath) {
        let task = viewModel.pendingTasks[indexPath.item]
        let vc = CreateTaskViewController(viewModel: viewModel, taskToEdit: task)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    public func goBack(){
        navigationController.popViewController(animated: true)
    }
}
