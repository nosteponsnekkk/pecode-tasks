//
//  CreateTaskViewController.swift
//  Pecode-Tasks-Test
//
//  Created by Oleg on 17.05.2024.
//

import UIKit

public final class CreateTaskViewController: UIViewController {

    weak var coordinator: MainCoordinator?
    private let viewModel: TaskViewModel
    private let taskModel: TaskModel?
    
    //MARK: - Handling keyboard state
    private var tapGesture: UITapGestureRecognizer?
    private var didExpand = false
    private var spacing: CGFloat = 0

    //MARK: - Subviews
    private lazy var createController: CreateTaskController = {
        let controller = CreateTaskController(taskToEdit: taskModel)
        return controller
    }()
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .mainColor
        button.configuration = .tinted()
        button.addTarget(self, action: #selector(createTask), for: .touchUpInside)
        button.setTitle("Save Task", for: .normal)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        return button
    }()
    
    //MARK: - Init
    init(viewModel: TaskViewModel, taskToEdit: TaskModel? = nil) {
        self.taskModel = taskToEdit
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.isToolbarHidden = true
    }
    public override func viewDidLayoutSubviews() {
        let controllerWidth: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? (view.bounds.width - 40) : (view.bounds.width/1.5)
        let controllerHeight: CGFloat = controllerWidth * 1.5
        
        createController.frame = CGRect(x: view.bounds.midX - (controllerWidth)/2,
                                        y: view.safeAreaInsets.top + 20,
                                        width: controllerWidth,
                                        height: controllerHeight)
        
        let createButtonHeight: CGFloat = 40
        createButton.frame = .init(x: view.bounds.midX - (controllerWidth)/2,
                                   y: createController.frame.maxY + 20,
                                   width: controllerWidth,
                                   height: createButtonHeight)

    }
    
    //MARK: - Methods
    private func setupView(){
        navigationController?.navigationBar.tintColor = .mainColor
        view.backgroundColor = .systemBackground
        title = taskModel != nil ? "Edit Task": "Create Task"
        view.addSubview(createController)
        view.addSubview(createButton)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:)))
        if let tapGesture {
            tapGesture.cancelsTouchesInView = false
            view.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc private func keyboardWillShow(notification: NSNotification){
        if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if !didExpand && createController.frame.intersects(keyboardRect) {
                spacing = view.bounds.height - createButton.frame.maxY
                createController.moveScroll(by: spacing)
                didExpand = true
            } else { return }
        }

    }
    @objc private func keyboardWillHide(notification: NSNotification){
        if didExpand {
            createController.moveScroll(by: 0)
            didExpand = false
        } else { return }
    }
    @objc private func createTask(){
        guard let taskModel = createController.getTaskModel() else {
            presentAlert(withTitle: "Error", 
                         withMessage: "Please enter a valid title for your task",
                         witCancelName: "Ok")
            return
        }
        if let oldTask = self.taskModel {
            viewModel.editTask(oldTask, newTask: taskModel)
        } else {
            viewModel.createTask(taskModel)
        }
        coordinator?.goBack()
    }
    @objc private func hideKeyboard(_ sender: UITapGestureRecognizer){
        guard !createController.doFieldsContain(touch: CGPoint(x: sender.location(in: createController).x,
                                                               y: sender.location(in: createController).y + Double(spacing))) else { return }
        createController.hideKeyboard()
    }
}
