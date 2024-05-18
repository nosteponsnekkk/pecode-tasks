//
//  CoreDataManager.swift
//  Pecode-Tasks-Test
//
//  Created by Oleg on 17.05.2024.
//

import CoreData
import Foundation

//MARK: - Constants for CoreData Manager
fileprivate struct CoreDataConstants {
    static let dataBase_name        = "CoreDataModel"
    static let taskEntity_name = "TaskEntity"
}

//MARK: - CoreData Manager
public final class CoreDataManager {
    
    public static let shared = CoreDataManager()
    private init(){}
    
    private lazy var mainContext: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    private lazy var backgroundContext: NSManagedObjectContext = {
        return persistentContainer.newBackgroundContext()
    }()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: CoreDataConstants.dataBase_name)
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("❌ Unresolved error \(error)")
            }
        }
        return container
    }()
    
    private func saveBackgroundContext() {
        
        do {
            try backgroundContext.save()
            mainContext.performAndWait {
                do {
                    try mainContext.save()
                } catch {
                    print("⚠️ CoreData Save Main Context Error: \(error.localizedDescription)")
                }
            }
        } catch {
            print("⚠️ CoreData Save Background Context Error: \(error.localizedDescription)")
        }
    }
    
    
    
}

//MARK: - CRUD
extension CoreDataManager {
    
    //MARK: Create
    public func createTaskEntity(_ model: TaskModel?){
        guard let model else { return }
        backgroundContext.perform { [weak self] in
            guard let self else { return }
            if let entityDescription = NSEntityDescription.entity(forEntityName: CoreDataConstants.taskEntity_name, in: backgroundContext) {
                let entity = TaskEntity(entity: entityDescription, insertInto: backgroundContext)
                
                entity.titleText        = model.title
                entity.descriptionText  = model.description
                entity.completionDate   = model.completionDate
                entity.isCompleted      = model.isCompleted
                
                saveBackgroundContext()
                
            } else {
                print("⚠️ CoreData creating error: entity description is nil")
            }
        }
    }
    
    //MARK: Read
    public func readAllTaskEntities() async -> [TaskModel] {
        return await backgroundContext.perform { [weak self] in
            guard let self else { return [] }
            
            let fetchRequest = NSFetchRequest<TaskEntity>(entityName: CoreDataConstants.taskEntity_name)
            
            do {
                let result = try backgroundContext.fetch(fetchRequest)
                return result.map({ TaskModel($0) })
            } catch {
                print("⚠️ CoreData reading error: \(error.localizedDescription)")
                return []
            }
        }
    }
    
    //MARK: Update
    public func updateTaskEntity(_ model: TaskModel?, with newModel: TaskModel?){
        guard let title = model?.title,
              let description = model?.description,
              let completionDate = model?.completionDate,
              let isCompleted = model?.isCompleted,
              let newModel
        else { return }
        
        backgroundContext.perform { [weak self] in
            guard let self else { return }
            let fetchRequest = NSFetchRequest<TaskEntity>(entityName: CoreDataConstants.taskEntity_name)
            
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(
                format: "titleText == %@ AND descriptionText == %@ AND completionDate == %@ AND isCompleted == %@",
                argumentArray: [title, description, completionDate, isCompleted])
            
            do {
                if let result = try backgroundContext.fetch(fetchRequest).first {
                    
                    result.titleText        = newModel.title
                    result.descriptionText  = newModel.description
                    result.completionDate   = newModel.completionDate
                    result.isCompleted      = newModel.isCompleted
                    
                    saveBackgroundContext()
                } else {
                    print("⚠️ CoreData updating error: entity is not found")
                    return
                }
            } catch {
                print("⚠️ CoreData updating error: \(error.localizedDescription)")
                return
            }
            
        }
    }
    
    //MARK: Delete
    public func deleteTaskEntity(_ model: TaskModel?){
        guard let title = model?.title,
              let description = model?.description,
              let completionDate = model?.completionDate,
              let isCompleted = model?.isCompleted else { return }
        
        backgroundContext.perform { [weak self] in
            guard let self else { return }
            let fetchRequest = NSFetchRequest<TaskEntity>(entityName: CoreDataConstants.taskEntity_name)
            
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(
                format: "titleText == %@ AND descriptionText == %@ AND completionDate == %@ AND isCompleted == %@",
                argumentArray: [title, description, completionDate, isCompleted])
            
            do {
                if let result = try backgroundContext.fetch(fetchRequest).first {
                    backgroundContext.delete(result)
                    saveBackgroundContext()
                } else {
                    print("⚠️ CoreData deleting error: entity is not found")
                    return
                }
            } catch {
                print("⚠️ CoreData deleting error: \(error.localizedDescription)")
                return
            }
            
        }
        
    }
    public func deleteAllCompletedTaskEntities(){
        backgroundContext.perform { [weak self] in
            guard let self else { return }
            let fetchRequest = NSFetchRequest<TaskEntity>(entityName: CoreDataConstants.taskEntity_name)
            
            do {
                let result = try backgroundContext.fetch(fetchRequest).filter({ $0.isCompleted })
                result.forEach { self.backgroundContext.delete($0) }
                saveBackgroundContext()
            } catch {
                print("⚠️ CoreData deleting error: \(error.localizedDescription)")
                return
            }
            
        }
    }

    public func deleteAllTaskEntities(){
        backgroundContext.perform { [weak self] in
            guard let self else { return }
            let fetchRequest = NSFetchRequest<TaskEntity>(entityName: CoreDataConstants.taskEntity_name)
            
            do {
                let result = try backgroundContext.fetch(fetchRequest)
                result.forEach { self.backgroundContext.delete($0) }
                saveBackgroundContext()
            } catch {
                print("⚠️ CoreData deleting error: \(error.localizedDescription)")
                return
            }
            
        }
    }
    
}
