//
//  DateExtension.swift
//  CalendarView
//
//  Created by Максим Голов on 03.04.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import Foundation

enum DateFormattingStyle {
    /// пн, 13 января  /  Mon, January 13
    case short
    /// понедельник, 13 января 2020 г.  /  Monday, January 13, 2020
    case full
    /// 13 января 2020 г.  /  January 13, 2020
    case long
    /// 13 января  /  January 13
    case dayAndMonth
    /// январь 2020 г.  /  January 2020
    case monthAndYear
    /// 9:41  /  9:41 AM
    case time
}

extension DateFormatter {
    static let shortFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("EdMMMM")
        return dateFormatter
    }()
        
    static let dayAndMonthFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("dMMMM")
        return dateFormatter
    }()
    
    static let monthAndYearFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("LLLLyyyy")
        return dateFormatter
    }()
}

extension Date {
    /// Количество дней в месяце
    var numberOfDaysInMonth: Int {
        return Calendar.current.range(of: .day, in: .month, for: self)!.count
    }

    var firstDayOfMonth: Int {
        let day = Calendar.current.component(.weekday, from: self) - 2
        return day == -1 ? 6 : day
    }
    
    /// День
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    /// Месяц
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    /// Год
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    init(day: Int, month: Int, year: Int, hours: Int = 0, minutes: Int = 0) {
        let components = DateComponents(year: year, month: month, day: day, hour: hours, minute: minutes)
        let date = Calendar.current.date(from: components)!
        self.init(timeIntervalSinceReferenceDate: date.timeIntervalSinceReferenceDate)
    }
    
    /// Строковое представление даты в формате `style`
    func string(style: DateFormattingStyle) -> String {
        switch style {
        case .short:
            return DateFormatter.shortFormatter.string(from: self)
        case .full:
            return DateFormatter.localizedString(from: self, dateStyle: .full, timeStyle: .none)
        case .long:
            return DateFormatter.localizedString(from: self, dateStyle: .long, timeStyle: .none)
        case .dayAndMonth:
            return DateFormatter.dayAndMonthFormatter.string(from: self)
        case .monthAndYear:
            return DateFormatter.monthAndYearFormatter.string(from: self)
        case .time:
            return DateFormatter.localizedString(from: self, dateStyle: .none, timeStyle: .short)
        }
    }
    
    // FIXME: ⚠️ Сегодняшняя дата подменена здесь ⚠️
    /// Дата, соответвующая сегодняшнему дню
    static var today: Date {
        let components = Calendar.current.dateComponents([.hour, .minute], from: Date())
        return Date(day: 26, month: 3, year: 2019,
                    hours: components.hour!,
                    minutes: components.minute!)
        // return Date()
    }
}
