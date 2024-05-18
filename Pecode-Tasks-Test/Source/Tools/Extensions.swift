//
//  Extensions.swift
//  Pecode-Tasks-Test
//
//  Created by Oleg on 17.05.2024.
//

import UIKit

//MARK: - UIColor
extension UIColor {
    static let mainColor = UIColor(named: "MainColor") ?? .black
    static let mainRed = #colorLiteral(red: 0.7017963435, green: 0.1028469657, blue: 0.1661883503, alpha: 1)
    static let mainGreen = #colorLiteral(red: 0, green: 0.5603182912, blue: 0, alpha: 1)
    static let mainYellow = #colorLiteral(red: 0.7766481638, green: 0.5705983043, blue: 0, alpha: 1)
    static let separatorColor = UIColor(named: "GrayScales") ?? .separator
}

//MARK: - Images
extension UIImage {
    static func createIcon(withConfiguration configuration: SymbolConfiguration) -> UIImage? {
        UIImage(systemName: "plus.circle.fill", withConfiguration: configuration)
    }
    static func filterIcon(withConfiguration configuration: SymbolConfiguration) -> UIImage? {
        UIImage(systemName: "line.3.horizontal.decrease.circle.fill", withConfiguration: configuration)
    }
    static func deleteIcon(withConfiguration configuration: SymbolConfiguration) -> UIImage? {
        UIImage(systemName: "trash.circle.fill", withConfiguration: configuration)
    }
    func addText(text: String, font: UIFont = .systemFont(ofSize: 14), textColor: UIColor = .white, padding: CGFloat = 5) -> UIImage? {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor
        ]
        let image = withTintColor(textColor, renderingMode: .alwaysTemplate)
        let textSize = (text as NSString).size(withAttributes: attributes)
        
        let newSize = CGSize(width: max(image.size.width, textSize.width), height: image.size.height + textSize.height + padding)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        
        image.draw(in: CGRect(x: (newSize.width - image.size.width) / 2, y: 0, width: image.size.width, height: image.size.height))
        
        let textRect = CGRect(x: (newSize.width - textSize.width) / 2, y: image.size.height + padding, width: textSize.width, height: textSize.height)
        (text as NSString).draw(in: textRect, withAttributes: attributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

//MARK: - TableView
extension UITableView {
    func register<T: UITableViewCell>(_ class: T.Type) {
            register(T.self, forCellReuseIdentifier: String(describing: `class`))
        }
        
        func dequeueReusableCell<T: UITableViewCell>(withClass class: T.Type, for indexPath: IndexPath) -> T {
            guard let cell = dequeueReusableCell(withIdentifier: String(describing: `class`), for: indexPath) as? T else {
                fatalError()
            }
            return cell
        }
}

//MARK: - UIViewController
extension UIViewController {
    func presentAlert(withTitle title: String? = nil,
                      withMessage message: String? = nil,
                      withActionName name: String? = nil,
                      witCancelName cancelName: String = "Cancel",
                      completion: ((UIAlertAction) -> Void)? = nil) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.view.tintColor = .mainColor
        let cancelAction = UIAlertAction(title: cancelName, style: .cancel)
        ac.addAction(cancelAction)
        if let completion, let name {
            let completionAction = UIAlertAction(title: name, style: .default, handler: completion)
            ac.addAction(completionAction)
        }
        
        present(ac, animated: true)
    }
}
//MARK: - Date
extension Date {
    func toString() -> String {
        let calendar = Calendar.current
        let currentDate = Date()
        let dateFormatter = DateFormatter()

        // Check if the date is today
            if calendar.isDateInToday(self) {
                dateFormatter.dateFormat = "HH:mm"
                return "Today\n\(dateFormatter.string(from: self))"
            }
            
            // Check if the date is tomorrow
            if calendar.isDateInTomorrow(self) {
                dateFormatter.dateFormat = "HH:mm"
                return "Tomorrow\n\(dateFormatter.string(from: self))"
            }
        
        if calendar.isDate(self, equalTo: currentDate, toGranularity: .weekOfYear) {
            // Date is in the same week
            dateFormatter.dateFormat = "EEEE\nHH:mm" // Full day name and time
            return dateFormatter.string(from: self)
        } else if calendar.isDate(self, equalTo: currentDate, toGranularity: .month) {
            // Date is in the same month
            dateFormatter.dateFormat = "EEEE\nd\nHH:mm" // Short day name, day of the month, and time
            return dateFormatter.string(from: self)
        } else if !calendar.isDate(self, equalTo: currentDate, toGranularity: .year) {
            // Date is not in the same year
            dateFormatter.dateFormat = "Y\nMMM, d\nHH:mm" // Day number, month number, and time
            return dateFormatter.string(from: self)
        } else {
            // Date is in the same year but not in the same week or month
            dateFormatter.dateFormat = "EEEE\nMMM, d\nHH:mm" // Day number, short month name, and time
            return dateFormatter.string(from: self)
        }
    }
}

//MARK: - UILabel
extension UILabel {
    func maxNumberOfLines(in width: CGFloat) -> Int {
            let maxSize = CGSize(width: width, height: CGFloat(Float.infinity))
            let charSize = font.lineHeight
            let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font as Any], context: nil)
            let linesRoundedUp = Int(ceil(textSize.height/charSize))
            return linesRoundedUp
        }
}
