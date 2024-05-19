//
//  TaskEntity+CoreDataClass.swift
//  Pecode-Tasks-Test
//
//  Created by Oleg on 17.05.2024.
//
//

import Foundation
import CoreData

@objc(TaskEntity)
public class TaskEntity: NSManagedObject {

}

extension TaskEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        return NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }

    @NSManaged public var titleText: String?
    @NSManaged public var descriptionText: String?
    @NSManaged public var completionDate: Date?
    @NSManaged public var creationDate: Date?
    @NSManaged public var isCompleted: Bool

}

extension TaskEntity : Identifiable {

}
