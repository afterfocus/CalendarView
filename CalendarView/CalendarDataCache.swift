//
//  CalendarData.swift
//  CalendarView
//
//  Created by Максим Голов on 03.04.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

// MARK: - MonthData

class MonthData {
    /// Дата, связанная с первым днём месяца
    let date: Date
    /// Номер дня недели первого дня месяца (понедельник = 0)
    lazy var firstDay = date.firstDayOfMonth
    /// Количество дней в месяце
    lazy var numberOfDays = date.numberOfDaysInMonth
    /// Количество строк в секции = (кол-во дней в месяце + первый день месяца) div 7
    lazy var numberOfRows = Int(ceil(Double(firstDay + numberOfDays) / 7))
    
    init(date: Date) {
        self.date = date
    }
}

// MARK: - CalendarDataCache

class CalendarDataCache {
    let initialDate: Date
    var monthsData = [MonthData]()
    
    init(initialYear: Int, numberOfYears: Int) {
        self.initialDate = Calendar.current.date(from: DateComponents(year: initialYear, month: 1, day: 1))!
        self.monthsData = (0...numberOfYears * 12).map {
            MonthData(date: Calendar.current.date(byAdding: .month, value: $0, to: initialDate)!)
        }
    }
    
    /// Получить данные для секции календаря с индексом `index`
    subscript(index: Int) -> MonthData {
        return monthsData[index]
    }
    
    func dateFor(_ indexPath: IndexPath) -> Date {
        let monthAndYear = monthsData[indexPath.section].date
        return Calendar.current.date(byAdding: .day, value: indexPath.item - 1, to: monthAndYear)!
    }
}
