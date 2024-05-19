//
//  TaskModel.swift
//  Pecode-Tasks-Test
//
//  Created by Oleg on 17.05.2024.
//

import Foundation

public struct TaskModel: Equatable {
    
    init(title: String, description: String, creationDate: Date, completionDate: Date, isCompleted: Bool = false) {
        self.title = title
        self.description = description
        self.completionDate = completionDate
        self.isCompleted = isCompleted
        self.creationDate = creationDate
    }
    init(_ entity: TaskEntity) {
        self.title = entity.titleText ?? ""
        self.description = entity.descriptionText ?? ""
        self.completionDate = entity.completionDate ?? Date()
        self.isCompleted = entity.isCompleted
        self.creationDate = entity.creationDate ?? Date()
    }
    
    let title: String
    let description: String
    let completionDate: Date
    let isCompleted: Bool
    let creationDate: Date
}
