//
//  CalendarCollectionCell.swift
//  Clients
//
//  Created by Максим Голов on 21.01.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

/// Ячейка календаря
public class CalendarViewCell: UICollectionViewCell {
    
    // MARK: IBOutlets

    /// Метка числа
    @IBOutlet weak var numberLabel: UILabel!
    /// Индикатор выбора ячейки
    @IBOutlet weak var circleView: UIView!
    /// Массив индикаторов записей
    @IBOutlet var visitIndicators: [UIView]!

    // MARK: -

    // Подготовить ячейку к переиспользованию
    override public func prepareForReuse() {
        super.prepareForReuse()
        circleView.backgroundColor = nil
        // Спрятать все индикаторы записей
        visitIndicators.forEach {
            $0.isHidden = true
            $0.backgroundColor = nil
        }
    }
    
    /**
     Заполнить ячейку данными
     - Parameters:
        - day: День месяца
        - visits: Массив записей для отображения индикаторов
        - isPicked: Является ли ячейка выбранной в данный момент (значение `true` отображает индикатор выбора ячейки)
        - isToday: Является ли день месяца сегодняшним (значение `true` меняет цвет числа и
        индикатора выбора ячейки на красный)
        - isWeekend: Является ли день месяца выходным (значение `true` меняет цвет числа на серый)
     
     Ячейка отображает до 6 индикаторов записей.
     */
    public func configure(day: Int,
                          indicatorColors: [UIColor],
                          isPicked: Bool,
                          isToday: Bool,
                          isWeekend: Bool) {
        numberLabel.text = "\(day)"
        if isPicked {
            circleView.backgroundColor = isToday ? .systemRed : .label
            numberLabel.textColor = isToday ? .white : .systemBackground
            numberLabel.font = .boldSystemFont(ofSize: 18)
        } else {
            if isToday {
                numberLabel.textColor = .systemRed
                numberLabel.font = .boldSystemFont(ofSize: 18)
            } else {
                numberLabel.textColor = isWeekend ? .gray : .label
                numberLabel.font = .systemFont(ofSize: 18)
            }
        }
        for (index, color) in indicatorColors.enumerated() where index < 6 {
            visitIndicators[index].backgroundColor = color
            visitIndicators[index].isHidden = false
        }
    }
}
