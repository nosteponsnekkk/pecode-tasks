//
//  TaskTableViewCell.swift
//  Pecode-Tasks-Test
//
//  Created by Oleg on 17.05.2024.
//

import UIKit

public protocol TaskTableViewCellExpandableDelegate: AnyObject {
    func didTapExpand(from cell: TaskTableViewCell)
    func didTapCollapse(from cell: TaskTableViewCell)
}

public final class TaskTableViewCell: UITableViewCell {
    
    public var isExpanded = false
    private var isCompleted = false
    
    weak var delegate: TaskTableViewCellExpandableDelegate?
    
    //MARK: - Subivews
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    private lazy var expandButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .mainColor
        button.configuration = .tinted()
        button.isHidden = true
        button.addTarget(self, action: #selector(didTapExpand), for: .touchUpInside)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        return button
    }()
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textAlignment = .right
        return label
    }()
    //MARK: - Init
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(expandButton)
        contentView.addSubview(dateLabel)
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        descriptionLabel.numberOfLines = 0
        titleLabel.numberOfLines = 0
        setupExpandButton()
        
        setupLabelSizes()
        
        dateLabel.frame = .init(x: bounds.maxX - 80 - 20, y: 0, width: 80, height: bounds.height)
        expandButton.frame = CGRect(x: 20,
                                    y: descriptionLabel.frame.maxY + 10,
                                    width: contentView.bounds.width - 120,
                                    height: 40)
        
        
    }
    
    //MARK: - Methods
    private func setupExpandButton() {
        expandButton.setTitle(isExpanded ? "Collapse" : "Expand" , for: .normal)
        
        if getDesiredHeight() >= 70  {
            expandButton.isHidden = false
        } else {
            expandButton.isHidden = true
        }
    }
    private func setupLabelSizes() {
        let textWidth: CGFloat = bounds.width - 120
        let desiredDescriptionLinesCount = descriptionLabel.maxNumberOfLines(in: textWidth)
        
        if isExpanded {
            setLabelsForExpandedState()
        } else {
            setLabelsForCollapsedState(desiredDescriptionLinesCount: desiredDescriptionLinesCount)
        }
        
        layoutLabels()
    }
    private func setLabelsForExpandedState() {
        titleLabel.numberOfLines = 0
        descriptionLabel.numberOfLines = 0
    }
    private func setLabelsForCollapsedState(desiredDescriptionLinesCount: Int) {
        if descriptionLabel.text?.isEmpty == true {
            titleLabel.numberOfLines = 3
        } else if desiredDescriptionLinesCount == 1 {
            titleLabel.numberOfLines = 2
        } else {
            descriptionLabel.numberOfLines = min(desiredDescriptionLinesCount, 2)
            titleLabel.numberOfLines = descriptionLabel.numberOfLines - 1
        }
    }
    private func layoutLabels() {
        let labelWidth = bounds.width - 120
        titleLabel.frame = CGRect(
            x: 20,
            y: 5,
            width: labelWidth,
            height: titleLabel.sizeThatFits(CGSize(width: labelWidth, height: .greatestFiniteMagnitude)).height
        )
        
        descriptionLabel.frame = CGRect(
            x: 20,
            y: titleLabel.frame.maxY + 5,
            width: labelWidth,
            height: descriptionLabel.sizeThatFits(CGSize(width: labelWidth, height: .greatestFiniteMagnitude)).height
        )
    }
    
    @objc private func didTapExpand(){
        if !isExpanded {
            delegate?.didTapExpand(from: self)
        } else {
            delegate?.didTapCollapse(from: self)
        }
    }
    
    //MARK: - Interfaces
    public func configure(with model: TaskModel?) {
        guard let model else { return }
        titleLabel.text = model.title
        descriptionLabel.text = model.description
        dateLabel.text = "\(model.completionDate.toString())"
        isCompleted = model.isCompleted
        
        if model.completionDate <= .now && !model.isCompleted {
            dateLabel.textColor = .mainRed
            titleLabel.textColor = .label
            descriptionLabel.textColor = .label
        } else {
            titleLabel.textColor = model.isCompleted == true ? .placeholderText : .label
            descriptionLabel.textColor = model.isCompleted == true ? .placeholderText : .label
            dateLabel.textColor = model.isCompleted == true ? .placeholderText : .label
        }
    }
    public func getDesiredHeight() -> CGFloat {
        let dateWidth: CGFloat = 80
        let textWidth: CGFloat = bounds.width - 120
                
        let desiredDateLabelHeight = dateLabel.sizeThatFits(.init(width: dateWidth, height: .greatestFiniteMagnitude)).height
        let desiredTitleHeight = titleLabel.sizeThatFits(.init(width: textWidth, height: .greatestFiniteMagnitude)).height
        let desiredDescriptionHeight = descriptionLabel.sizeThatFits(.init(width: textWidth, height: .greatestFiniteMagnitude)).height
        let offsets: CGFloat = 10
        
        let desiredContentHeight = desiredTitleHeight + desiredDescriptionHeight + offsets
        
        if desiredDateLabelHeight + offsets >= desiredContentHeight {
            return desiredDateLabelHeight + offsets
        } else {
            return desiredContentHeight
        }
    }
    
}
