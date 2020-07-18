//
//  CalendarView.swift
//  Clients
//
//  Created by Максим Голов on 23.02.2020.
//  Copyright © 2020 Максим Голов. All rights reserved.
//

import UIKit

// MARK: - CalendarViewDataSource

@objc public protocol CalendarViewDataSource: class {
    func calendarView(_ calendarView: CalendarView, isDayAWeekendFor date: Date) -> Bool
    func calendarView(_ calendarView: CalendarView, indicatorColorsFor date: Date) -> [UIColor]
}

// MARK: - CalendarViewDelegate

@objc public protocol CalendarViewDelegate: class {
    func calendarView(_ calendarView: CalendarView, didSelectCellFor date: Date)
    func calendarView(_ calendarView: CalendarView, didSelectSectionFor date: Date, withNumberOfRows rows: Int)
    func calendarView(_ calendarView: CalendarView, didSetIsPagindEnabled isPagingEnabled: Bool)
}

// MARK: - CalendarView

public class CalendarView: UICollectionView {
    /// Представление названия месяца для свободного режима пролистывания
    @IBOutlet weak var monthGradientView: MonthGradientView?
    @IBOutlet weak var calendarDelegate: CalendarViewDelegate?
    @IBOutlet weak var calendarDataSource: CalendarViewDataSource?
    @IBInspectable var initialYear = 2018
    @IBInspectable var numberOfYears = 10
    
    public lazy var cellSize = {
        return CGSize(width: frame.width / 7 - 0.00001, height: (frame.height - 40) / 6)
    }()
    
    public lazy var sectionHeight = {
        return cellSize.height * 6 + 40
    }()

    public var todayCell: IndexPath
    public var pickedCell: IndexPath {
        didSet {
            guard pickedCell != oldValue else { return }
            calendarDelegate?.calendarView(self, didSelectCellFor: calendarDataCache.dateFor(pickedCell))
            reloadItemsWithoutAnimation(at: [pickedCell, oldValue])
        }
    }
    private var calendarDataCache: CalendarDataCache
    /// Генератор обратной связи (для щелчков при пролистывании календаря)
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    public var currentSection: Int {
        let section = Int(round(contentOffset.y / sectionHeight))
        return section < 0 ? 0 : section
    }
    
    public var dateForCurrentSection: Date {
        return calendarDataCache[currentSection].date
    }
    
    public var dateForPickedCell: Date {
        return calendarDataCache.dateFor(pickedCell)
    }
    
    public var numberOfRowsInCurrentSection: Int {
        return calendarDataCache[currentSection].numberOfRows
    }
    
    public override var isPagingEnabled: Bool {
        didSet {
            // Корректировать положение календаря, если включен постраничный режим
            if isPagingEnabled {
                scrollTo(section: pickedCell.section)
            }
            calendarDelegate?.calendarView(self, didSetIsPagindEnabled: isPagingEnabled)
        }
    }
    
    public required init?(coder: NSCoder) {
        let today = Date.today
        let todaySection = (today.year - initialYear) * 12 + today.month - 1
        todayCell = IndexPath(item: today.day, section: todaySection)
        pickedCell = todayCell
        
        calendarDataCache = CalendarDataCache(initialYear: initialYear, numberOfYears: numberOfYears)
        
        super.init(coder: coder)
        scrollsToTop = false
        delegate = self
        dataSource = self
        
        // Регистрация ячейки календаря
        let cellNib = UINib(nibName: "CalendarViewCell",
                            bundle: Bundle(identifier: "MaximGolov.CalendarView"))
        register(cellNib, forCellWithReuseIdentifier: "CalendarViewCell")
        
        let placeholderNib = UINib(nibName: "CalendarViewPlaceholderCell",
                            bundle: Bundle(identifier: "MaximGolov.CalendarView"))
        register(placeholderNib, forCellWithReuseIdentifier: "CalendarViewPlaceholderCell")
        
        // Регистрация заголовка секции календаря
        let headerNib = UINib(nibName: "CalendarViewHeader",
                              bundle: Bundle(identifier: "MaximGolov.CalendarView"))
        register(headerNib,
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                 withReuseIdentifier: "CalendarViewHeader")
    }

    public func scrollTo(section: Int, animated: Bool = true) {
        let y = sectionHeight * CGFloat(section)
        setContentOffset(CGPoint(x: 0, y: y), animated: animated)
        
        calendarDelegate?.calendarView(self, didSelectSectionFor: calendarDataCache[section].date,
                                       withNumberOfRows: calendarDataCache[section].numberOfRows)
    }
    
    public func reloadItemsWithoutAnimation(at indexPaths: [IndexPath]) {
        UIView.performWithoutAnimation {
            self.reloadItems(at: indexPaths)
        }
    }
    
    /// Пролистывает календарь обратно к текущему месяцу или воспроизводит анимацию
    /// подпрыгивания, если в календаре уже отображается текущий месяц.
    public func scrollToTodayCell() {
        if todayCell.section != currentSection {
            pickedCell = todayCell
            scrollTo(section: todayCell.section)
        } else {
            jump()
        }
    }

    public func jump() {
        UIView.animate(withDuration: 0.2) {
            self.contentOffset.y -= 45
        }
        UIView.animate(withDuration: 0.25, delay: 0.2, animations: {
            self.contentOffset.y += 60
        })
        UIView.animate(withDuration: 0.2, delay: 0.4, options: .curveEaseOut, animations: {
            self.contentOffset.y -= 15
        })
    }
}

// MARK: - UICollectionViewDelegate

extension CalendarView: UICollectionViewDelegate {

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        pickedCell = indexPath
        if !isPagingEnabled {
            isPagingEnabled = true
        }
    }
}

// MARK: - UICollectionViewDataSource

extension CalendarView: UICollectionViewDataSource {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        numberOfYears * 12
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let monthData = calendarDataCache[section]
        return max(monthData.numberOfDays + 1, 37 - monthData.firstDay)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Первая ячейка - невидимая заглушка изменяемой ширины для корректировки
        // положения первой видимой ячейки в зависимости от первого дня месяца.
        // Так же ячейки-заглушки могут понадобиться в конце для дополнения секции до 6 строк
        if indexPath.item == 0 || indexPath.item > calendarDataCache[indexPath.section].numberOfDays {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarViewPlaceholderCell",
                                                      for: indexPath)
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarViewCell",
                                                          for: indexPath) as! CalendarViewCell
            let date = calendarDataCache.dateFor(indexPath)
            // В ячейке отображаются номер дня месяца и индикаторы записей на этот день.
            cell.configure(
                day: indexPath.item,
                indicatorColors: calendarDataSource?.calendarView(self, indicatorColorsFor: date) ?? [],
                isPicked: pickedCell == indexPath,
                isToday: todayCell == indexPath,
                isWeekend: calendarDataSource?.calendarView(self, isDayAWeekendFor: date) ?? false
            )
            return cell
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               viewForSupplementaryElementOfKind kind: String,
                               at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CalendarViewHeader", for: indexPath) as! CalendarViewHeader
        // Текст = название месяца, связанного с секцией
        header.monthLabel.text = monthNameString(for: indexPath)
        // Цвет текста красный, если связанный месяц - текущий
        header.monthLabel.textColor = (indexPath.section == todayCell.section) ? .systemRed : .label
        // Горизонатальный центр метки совпадает с центром первой видимой ячейки секции
        header.moveCenterX(to: calendarDataCache[indexPath.section].firstDay, cellWidth: cellSize.width)
        return header
    }
    
    private func monthNameString(for indexPath: IndexPath) -> String {
        let monthName = Calendar.current.standaloneMonthSymbols[indexPath.section % 12]
        return monthName.prefix(1).capitalized + monthName.dropFirst()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CalendarView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0 {
            // Первая ячейка - невидимая заглушка изменяемой ширины для корректировки
            // положения первой видимой ячейки в зависимости от первого дня месяца.
            return CGSize(
                width: cellSize.width * CGFloat(calendarDataCache[indexPath.section].firstDay),
                height: cellSize.height)
        } else {
            return cellSize
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.frame.width, height: 40)
    }
}

// MARK: - UIScrollViewDelegate

extension CalendarView: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        monthGradientView?.text = calendarDataCache[currentSection].date.string(style: .monthAndYear)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                          withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        /// Индекс секции, которая будет отображена по окончании анимации пролистывания
        let targetSection = Int(round(targetContentOffset.pointee.y / sectionHeight))
        /// Дата (месяц и год), связанная с отображаемой секцией
        let targetMonth = calendarDataCache[targetSection].date
        
        if isPagingEnabled {
            // Выбрать первый день отображаемого месяца или сегодняшний день, если отображается текущий месяц
            var indexPath = IndexPath(item: 1, section: targetSection)
            if targetMonth.month == Date.today.month && targetMonth.year == Date.today.year {
                indexPath.item = Date.today.day
            }
            pickedCell = indexPath
            // Щёлк
            impactFeedbackGenerator.impactOccurred()
        } else if velocity.y.magnitude > 1 {
            // В свободном режиме при быстром пролистывании отобразить название месяца
            monthGradientView?.showAndSmoothlyDisappear()
        }
        calendarDelegate?.calendarView(self, didSelectSectionFor: targetMonth,
                                       withNumberOfRows: calendarDataCache[targetSection].numberOfRows)
    }
}
