//
//  TaskViewModel.swift
//  Pecode-Tasks-Test
//
//  Created by Oleg on 17.05.2024.
//

import Foundation
import Combine

public enum TaskSorting {
    case byCreationDate
    case byCompletionDate
    case byName
}
public final class TaskViewModel {
    
    @Published private var data: [TaskModel]  = []
    @Published public var sorting: TaskSorting = .byCompletionDate
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(){
        Task {
            await loadData()
        }
    }
    
    private func loadData() async {
        data = await CoreDataManager.shared.readAllTaskEntities()
    }
    
    
}

//MARK: - Interfaces
extension TaskViewModel {
    //MARK: Bind & Creation
    public func bind(dataHandler: @escaping (_ isDataEmpty: Bool) -> Void, 
                     filterHandler: @escaping () -> Void) {
        $data
            .receive(on: DispatchQueue.main)
            .sink { data in
                dataHandler(data.isEmpty)
            }
            .store(in: &cancellables)
        $sorting
            .receive(on: DispatchQueue.main)
            .sink { _ in
                filterHandler()
            }
            .store(in: &cancellables)
    }
    public func createTask(_ model: TaskModel){
        CoreDataManager.shared.createTaskEntity(model)
        Task {
            await loadData()
        }
    }
    
    //MARK: Delete
    public func clearAllTasks(){
        CoreDataManager.shared.deleteAllTaskEntities()
        Task {
            await loadData()
        }
    }
    public func clearCompletedTasks(){
        CoreDataManager.shared.deleteAllCompletedTaskEntities()
        Task {
            await loadData()
        }
    }
    public func deleteTask(_ task: TaskModel?) {
        guard let task else { return }
        CoreDataManager.shared.deleteTaskEntity(task)
        Task {
            await loadData()
        }
    }
    
    //MARK: Update
    public func editTask(_ task: TaskModel, newTask: TaskModel){
        CoreDataManager.shared.updateTaskEntity(task, with: newTask)
        Task {
            await loadData()
        }
    }
    public func markTaskAsCompleted(at indexPath: IndexPath){
        let task = pendingTasks[indexPath.row]
        CoreDataManager.shared.updateTaskEntity(task, with: TaskModel(title: task.title, description: task.description, creationDate: task.creationDate, completionDate: task.completionDate, isCompleted: true))
        Task {
            await loadData()
        }
    }
    
    //MARK: Data
    public var pendingTasks: [TaskModel] {
        let pendingTasks = data.filter({!$0.isCompleted})
        switch sorting {
        case .byCreationDate:
            return pendingTasks.sorted(by: { $0.creationDate > $1.creationDate })
        case .byCompletionDate:
            return pendingTasks.sorted(by: { $0.completionDate < $1.completionDate })
        case .byName:
            return pendingTasks.sorted(by: { $0.title < $1.title })
        }
    }
    public var completedTasks: [TaskModel] {
        let completedTasks = data.filter({$0.isCompleted})
        switch sorting {
        case .byCreationDate:
            return completedTasks.sorted(by: { $0.creationDate > $1.creationDate })
        case .byCompletionDate:
            return completedTasks.sorted(by: { $0.completionDate < $1.completionDate })
        case .byName:
            return completedTasks.sorted(by: { $0.title < $1.title })
        }
    }
}
