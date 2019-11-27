//
//  HashLabel.swift
//  HashLabelDemo
//
//  Created by Diego on 2019/8/26.
//  Copyright © 2019 whatzwhat. All rights reserved.
//
//  ------------------
// | 2019/08/27 - v0.1 第一版
// | 2019/09/17 - v0.2 移除 GameplayKit 改用 Int.Random
// | 2019/10/18 - v0.3 增加白名單功能
// | 2019/11/26 - v0.4 修正白名單成員依然會算進總動畫時間之問題
//  ------------------

import UIKit

extension HashLabel.Mode {
    
    var value: String {
        var number: Int
        switch self {
        case .default: // 預設(英文、符號、數字)
            number = random(from: 33, to: 126)
        case .no:      // 數字
            number = random(from: 48, to: 57)
        case .zh:      // 英文
            number = random(from: 13312, to: 40911)
        case .en:      // 中文
            number = random(from: 65, to: 122)
            while 90 < number && number < 97 { number = random(from: 65, to: 122) }
        }
        guard let unicode = UnicodeScalar(number) else { return self.value }
        return String(unicode)
    }
    
    private func random(from: Int, to: Int) -> Int {
        return Int.random(in: from...to)
    }
    
}


final class HashLabel: UILabel {
    
    enum Mode { case `default`, no, en, zh }
    
    enum StartPoint { case first, last }
    
    /// DisplayLink
    private var timer: CADisplayLink?
    /// 生成方向
    public var startPoint: StartPoint = .first
    /// 亂碼模式
    private(set) var mode: Mode = .default
    /// 動畫運行時間
    private(set) var totalTime: TimeInterval = 3
    /// 文字
    private var content: String = ""
    /// 開始時間
    private var startTime: TimeInterval = 0
    /// 進行時間
    private var progress: TimeInterval = 0
    /// 動畫變化區間
    private var timeSection: TimeInterval = 0
    /// 白名單
    public var whitelist: [String] = []
    /// 白名單補償時差
    private var compensationTime : TimeInterval = 0
    
}


// MARK: - Public Methods.
extension HashLabel {
    
    public func setText(_ text: String, duration: TimeInterval? = nil, mode: Mode? = nil) {
        resetProperty()
        recycleDisplayLink()
        if let duration = duration {
            totalTime = duration
        } else {
            totalTime = 3
        }
        if let mode = mode {
            self.mode = mode
        }
        content = text
        startTime = Date.timeIntervalSinceReferenceDate
        compensationMultiplier()
        timeSection = totalTime / Double(content.count)
        addDisplayLink()
    }
    
   
    /* 補償因為白名單的關係, 停滯的動畫時間
     
     - 實際的法是, 取得扣除掉白名單的文字長度, 除上總文字長度, 取得相對倍率後再乘上總動畫時間
     
     - 並在計算的時候, 補償(跳過)那一段區間的時間, 這樣就同時會相等使用者設定的動畫時間有可以跳過白名單的停滯時間
     
     */
    private func compensationMultiplier() {
        var actualText = content
        for white in whitelist {
            actualText = actualText.filter { char -> Bool in
                return String(char) != white
            }
        }
        let multiplier = Double(content.count) / Double(actualText.count)
        totalTime = totalTime * multiplier
    }
    
}


// MARK: - Action Methods.
extension HashLabel {

    private func recycleDisplayLink() {
        timer?.invalidate()
        timer = nil
    }
    
    private func resetProperty() {
        content = ""
        startTime = 0
        progress = 0
        timeSection = 0
        compensationTime = 0
    }
    
    private func addDisplayLink() {
        timer = CADisplayLink(target: self, selector: #selector(updateValue(timer:)))
        timer?.add(to: .main, forMode: .default)
        timer?.add(to: .main, forMode: .tracking)
    }
    
    @objc private func updateValue(timer: Timer) {
        let now = Date.timeIntervalSinceReferenceDate
        progress = (now - startTime) + compensationTime
        // 結束邏輯
        if progress >= totalTime {
            recycleDisplayLink()
        }
        // 計算亂碼長度
        let randomSize = content.count - Int(floor(progress / timeSection))
        // 準備容器
        var randomText = ""
        // 開始產生亂數
        for index in stride(from: 0, to: randomSize, by: 1) {
            
            // 確認白名單
            let text: String
            switch startPoint {
            case .first:
                let index = content.index(content.startIndex, offsetBy: abs(content.count - randomSize) + index)
                text = String(content[index])
            case .last:
                let index = content.index(content.startIndex, offsetBy: index)
                text = String(content[index])
            }
            if whitelist.contains(text) {
                randomText += text
            } else {
                randomText += mode.value
            }
            
        }
        // 白名單長度
        var whitelistCount: Double = 0
        // 計算正常字元的長度
        let textCount = content.count - randomSize
        // 容器
        var text = ""
        // 開始產生正常字元 ...
        for index in stride(from: 0, to: textCount, by: 1) {
            
            let textOfIndex: String
            switch startPoint {
            case .first:
                let index = content.index(content.startIndex, offsetBy: index)
                textOfIndex = String(content[index])
                text += textOfIndex
            case .last:
                // reversed
                let index = content.index(content.endIndex, offsetBy: -(index + 1))
                textOfIndex = String(content[index])
                text = textOfIndex + text
            }
            // 累加目前白名單長度
            if whitelist.contains(textOfIndex) {
                whitelistCount += 1
            }
            
        }
        // 補償白名單停滯時間
        compensationTime  = timeSection * whitelistCount
        // 產生結果
        switch startPoint {
        case .first:
            self.text = text + randomText
        case .last:
            self.text = randomText + text
        }
        
    }
    
    

}



