//
//  CreateTaskController.swift
//  Pecode-Tasks-Test
//
//  Created by Oleg on 18.05.2024.
//

import UIKit

public final class CreateTaskController: UIView {

    private let taskModel: TaskModel?
    
    //MARK: - Subviews
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    private lazy var pickerLabel: UILabel = {
        let label = UILabel()
        label.text = "Pick a date for your task"
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .inline
        picker.tintColor = .mainColor
        picker.minimumDate = .now
        let today = Date()
        let calendar = Calendar.current
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) {
            picker.date = tomorrow
        }
        return picker
    }()
    private lazy var titleField: UITextField = {
        let field = UITextField()
        field.tintColor = .mainColor
        field.placeholder = "Enter title for task"
        field.font = .systemFont(ofSize: 14)
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.gray.cgColor
        field.layer.borderWidth = 1
        field.clearButtonMode = .whileEditing
        field.leftView = UIView()
        field.leftView?.frame.size = .init(width: 20, height: 40)
        field.leftViewMode = .always
        field.delegate = self
        return field
    }()
    private lazy var descriptionField: UITextField = {
        let field = UITextField()
        field.tintColor = .mainColor
        field.placeholder = "Enter description for task"
        field.font = .systemFont(ofSize: 14)
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.gray.cgColor
        field.layer.borderWidth = 1
        field.clearButtonMode = .whileEditing
        field.leftView = UIView()
        field.leftView?.frame.size = .init(width: 20, height: 40)
        field.leftViewMode = .always
        field.delegate = self
        return field
    }()
    
    //MARK: - Init
    init(taskToEdit: TaskModel?){
        self.taskModel = taskToEdit
        super.init(frame: .zero)
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    public override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        
        pickerLabel.frame = .init(x: 10, y: 10, width: bounds.width - 20, height: 20)
        datePicker.frame = .init(x: 10,
                                 y: pickerLabel.frame.maxY + 10,
                                 width: bounds.width - 20,
                                 height: bounds.width)
        titleField.frame = .init(x: 10,
                                 y: datePicker.frame.maxY + 10,
                                 width: bounds.width - 20,
                                 height: 40)
        descriptionField.frame = .init(x: 10,
                                       y: titleField.frame.maxY + 10,
                                       width: bounds.width - 20,
                                       height: 40)
        scrollView.contentSize = CGSize(width: scrollView.bounds.width,
                                        height: 10 + pickerLabel.frame.height + 10 + datePicker.frame.height + 10 + titleField.frame.height + 10 + descriptionField.frame.height)
    }
    
    //MARK: - Methods
    private func setupView(){
        backgroundColor = .separatorColor
        layer.cornerRadius = 20
        clipsToBounds = true
        addSubview(scrollView)
        scrollView.addSubview(pickerLabel)
        scrollView.addSubview(datePicker)
        scrollView.addSubview(titleField)
        scrollView.addSubview(descriptionField)
        
        if let taskModel {
            titleField.placeholder = taskModel.title
            if !taskModel.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                descriptionField.placeholder = taskModel.description
            }
            if taskModel.completionDate > .now {
                datePicker.date = taskModel.completionDate
            }
        }
    }
    
    //MARK: - Interfaces
    public func getTaskModel() -> TaskModel? {
        let date = datePicker.date
        var title = ""
        var description = ""
        
        if titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
            title = taskModel?.title ?? ""
        } else {
            title = titleField.text ?? ""
        }
        if descriptionField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
            description = taskModel?.description ?? ""
        } else {
            description = descriptionField.text ?? ""
        }
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return TaskModel(title: title, description: description, completionDate: date)
        
    }
    public func hideKeyboard(){
        titleField.resignFirstResponder()
        descriptionField.resignFirstResponder()
    }
    public func moveScroll(by offset: CGFloat) {
        scrollView.contentOffset = CGPoint(x: 0, y: offset)
    }
}
//MARK: - Extensions
extension CreateTaskController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
