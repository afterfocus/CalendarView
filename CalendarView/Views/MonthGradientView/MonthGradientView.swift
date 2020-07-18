//
//  MonthGradientView.swift
//  Clients
//
//  Created by Максим Голов on 22.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

@IBDesignable
class MonthGradientView: UIView, NibLoadable {
    
    /// Метка названия месяца
    @IBOutlet weak var monthLabel: UILabel!
    /// Градиент под названием месяца
    private var gradient = CAGradientLayer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
        
        // Создание градиента под надписью месяца
        gradient.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 95)
        gradient.locations = [0.4, 1.0]
        gradient.colors = [UIColor.systemBackground.cgColor, UIColor.systemBackground.withAlphaComponent(0).cgColor]
        layer.insertSublayer(gradient, at: 0)
        
        alpha = 0
        monthLabel.alpha = 0
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
    }
    
    var text: String {
        get { return monthLabel.text! }
        set { monthLabel.text = newValue }
    }

    // Обновить цвета градиента под названием месяца при смене темы
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        gradient.colors = [UIColor.systemBackground.cgColor, UIColor.systemBackground.withAlphaComponent(0).cgColor]
    }

    func showAndSmoothlyDisappear() {
        alpha = 1
        monthLabel.alpha = 1
        // Анимировать исчезновение через 1 секунду
        UIView.animate(withDuration: 0.5, delay: 1.0, options: .curveEaseIn, animations: {
            self.monthLabel.alpha = 0
        })
        UIView.animate(withDuration: 0.8, delay: 1.0, options: .curveEaseIn, animations: {
            self.alpha = 0
        })
    }
}

public protocol NibLoadable {
    static var nibName: String { get }
}

public extension NibLoadable where Self: UIView {

    static var nibName: String {
        return String(describing: Self.self)
    }

    static var nib: UINib {
        let bundle = Bundle(for: Self.self)
        return UINib(nibName: Self.nibName, bundle: bundle)
    }

    func setupFromNib() {
        guard let view = Self.nib.instantiate(withOwner: self, options: nil).first as? UIView else { fatalError("Error loading \(self) from nib") }
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        view.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
    }
}
