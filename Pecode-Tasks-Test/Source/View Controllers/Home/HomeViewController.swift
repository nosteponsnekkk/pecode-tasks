//
//  HomeViewController.swift
//  Pecode-Tasks-Test
//
//  Created by Oleg on 17.05.2024.
//

import UIKit

public final class HomeViewController: UITableViewController {
    
    weak var coordinator: MainCoordinator?
    
    //MARK: - Data
    private let viewModel: TaskViewModel
    private var expandedIndexes: [IndexPath : TaskModel] = [:]

    //MARK: - Subviews
    private lazy var clearBarButton: CustomButtonItem = {
        let btn = CustomButtonItem(self, selector: #selector(didTapClear), type: .clear)
        btn.disable(animated: false)
        return btn
    }()
    private lazy var createBarButton: CustomButtonItem = {
        CustomButtonItem(self, selector: #selector(didTapCreate), type: .create)
    }()
    private lazy var sortBarButton: CustomButtonItem = {
        CustomButtonItem(self, selector: #selector(didTapSort), type: .filter)
    }()
    private lazy var clearRecentBarButton: CustomButtonItem = {
        CustomButtonItem(self, selector: #selector(didTapClearRecent), type: .clearRecent)
    }()
    
    private lazy var placeholderLabel: PlaceholderLabel = {
        PlaceholderLabel(firstPart: "Tasks are empty.\nTap ",
                         icon: UIImage(systemName: "plus.circle.fill"),
                         secondPart: " to create a new task")
    }()
    
    //MARK: - Init
    init(viewModel: TaskViewModel) {
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
        setupBindings()
    }
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = false
    }
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        placeholderLabel.frame = tableView.bounds
    }
    
    //MARK: - Methods
    private func setupView(){
        title = "Task Planner"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.titleTextAttributes = [
            .font : UIFont.boldSystemFont(ofSize: 20)
        ]
        navigationItem.rightBarButtonItem    = createBarButton
        navigationItem.leftBarButtonItem     = clearBarButton
        navigationItem.backButtonDisplayMode = .generic
        
        navigationController?.isToolbarHidden = false
        
        tableView.register(TaskTableViewCell.self)
        tableView.separatorColor = .separatorColor
        tableView.addSubview(placeholderLabel)
        
    }
    private func setupBindings(){
        viewModel.bind { [weak self] isDataEmpty in
            guard let self else { return }
            expandedIndexes = [:]
            if isDataEmpty {
                clearBarButton.disable()
                toolbarItems = []
            } else {
                clearBarButton.enable()
                if viewModel.completedTasks.isEmpty {
                    toolbarItems = [self.sortBarButton, .flexibleSpace()]
                } else {
                    toolbarItems = [self.sortBarButton, .flexibleSpace(), self.clearRecentBarButton]
                }
            }

            UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve) {
                self.tableView.reloadData()
                self.placeholderLabel.isHidden = !isDataEmpty
            } completion: { _ in
                self.tableView.isScrollEnabled = !isDataEmpty
            }

        } filterHandler: { [weak self] in
            guard let self else { return }
            UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve) {
                self.tableView.reloadData()
            }
        }

    }
    
    @objc private func didTapCreate(){
        coordinator?.createTask()
    }
    @objc private func didTapClear(){
        presentAlert(withTitle: "Are you sure?", 
                     withMessage: "Are you sure to delete all tasks?",
                     withActionName: "Confirm") { [weak self] _ in
            self?.viewModel.clearAllTasks()
        }
    }
    @objc private func didTapSort(){
        let ac = UIAlertController(title: "Sorting", message: "Choose preferred sorting option", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Default", style: .default) { [weak self] _ in
            guard let self else { return }
            viewModel.sorting = .default
        })
        ac.addAction(UIAlertAction(title: "By name", style: .default) { [weak self] _ in
            guard let self else { return }
            viewModel.sorting = .byName
        })
        ac.addAction(UIAlertAction(title: "By completion date", style: .default) { [weak self] _ in
            guard let self else { return }
            viewModel.sorting = .byDate
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.view.tintColor = .mainColor
        present(ac, animated: true)
    }
    @objc private func didTapClearRecent(){
        presentAlert(withTitle: "Are you sure?",
                     withMessage: "Are you sure to delete all completed tasks?",
                     withActionName: "Confirm") { [weak self] _ in
            self?.viewModel.clearCompletedTasks()
        }
    }
}


//MARK: - TableView Methods
extension HomeViewController: TaskTableViewCellExpandableDelegate {
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        var numberOfSections = 0
        
        if !viewModel.pendingTasks.isEmpty {
            numberOfSections += 1
        }
        if !viewModel.completedTasks.isEmpty {
            numberOfSections += 1
        }
        
        return numberOfSections
    }
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if viewModel.pendingTasks.isEmpty {
            return "Completed Tasks"
        } else {
            return section == 0 ? "Pending Tasks" : "Completed Tasks"
        }
    }
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if viewModel.pendingTasks.isEmpty {
            return viewModel.completedTasks.count
        } else {
            switch section {
            case 0:
                return viewModel.pendingTasks.count
            case 1:
                return viewModel.completedTasks.count
            default: return 0
            }
        }
    }
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: TaskTableViewCell.self, for: indexPath)
        
        var model: TaskModel?
        
        if viewModel.pendingTasks.isEmpty {
            model = viewModel.completedTasks[indexPath.row]
        } else {
            model = getItem(at: indexPath)
        }

        cell.configure(with: model)
        
        if expandedIndexes[indexPath] == model {
            cell.isExpanded = true
        } else {
            cell.isExpanded = false
        }
        cell.delegate = self
        return cell
    }
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            
        let cell = TaskTableViewCell(style: .default, reuseIdentifier: String(describing: TaskTableViewCell.self))
        cell.frame.size = .init(width: tableView.bounds.width, height: 70)

        var model: TaskModel?
        
        if viewModel.pendingTasks.isEmpty {
            model = viewModel.completedTasks[indexPath.row]
        } else {
            model = getItem(at: indexPath)
        }
        cell.configure(with: model)
        
        if expandedIndexes[indexPath] == model {
            //if cell is expanded
            return cell.getDesiredHeight() + 60
        }
        
        if cell.getDesiredHeight() >= 70 {
            //if cell is expandable
            return 125
        } else {
            //if cell is not expandable
            return 70
        }
        
    }
    
    public override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, _ in
            guard let self else { return }
            var model: TaskModel?
            
            if viewModel.pendingTasks.isEmpty {
                model = viewModel.completedTasks[indexPath.row]
            } else {
                model = getItem(at: indexPath)
            }
            viewModel.deleteTask(model)
        }
        deleteAction.backgroundColor = .mainRed
        deleteAction.image = UIImage(systemName: "trash")?.addText(text: "Delete")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    public override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !viewModel.pendingTasks.isEmpty && indexPath.section == 0 else { return nil }
        let markCompletedAction = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, _ in
            guard let self else { return }
            viewModel.markTaskAsCompleted(at: indexPath)
        }
        markCompletedAction.backgroundColor = .mainGreen
        markCompletedAction.image = UIImage(systemName: "checkmark")?.addText(text: "Complete")
        
        let editAction = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, _ in
            guard let self else { return }
            coordinator?.editTask(at: indexPath)
        }
        editAction.backgroundColor = .mainYellow
        editAction.image = UIImage(systemName: "pencil")?.addText(text: "Edit")
        
        
        return UISwipeActionsConfiguration(actions: [markCompletedAction, editAction])

    }
    public func didTapExpand(from cell: TaskTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell), let model = getItem(at: indexPath) else { return }
        expandedIndexes[indexPath] = model
        tableView.reloadRows(at: [indexPath], with: .automatic)

    }
    public func didTapCollapse(from cell: TaskTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        expandedIndexes[indexPath] = nil
        tableView.reloadRows(at: [indexPath], with: .automatic)

    }
    private func getItem(at indexPath: IndexPath) -> TaskModel? {
        switch indexPath.section {
        case 0:
            return viewModel.pendingTasks[indexPath.item]
        case 1:
            return viewModel.completedTasks[indexPath.item]
        default: return nil
        }

    }
}
