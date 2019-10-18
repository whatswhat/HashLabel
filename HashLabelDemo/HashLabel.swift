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
    /// 動畫時間
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

}


// MARK: - Public Methods.
extension HashLabel {
    
    public func setText(_ text: String, duration: TimeInterval? = nil, mode: Mode? = nil) {
        resetProperty()
        recycleDisplayLink()
        if let duration = duration {
            totalTime = duration
        }
        if let mode = mode {
            self.mode = mode
        }
        content = text
        startTime = Date.timeIntervalSinceReferenceDate
        timeSection = totalTime / Double(content.count)
        addDisplayLink()
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
    }
    
    private func addDisplayLink() {
        timer = CADisplayLink(target: self, selector: #selector(updateValue(timer:)))
        timer?.add(to: .main, forMode: .default)
        timer?.add(to: .main, forMode: .tracking)
    }
    
    @objc private func updateValue(timer: Timer) {
        let now = Date.timeIntervalSinceReferenceDate
        progress = now - startTime
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
        // 計算正常字元的長度
        let textCount = content.count - randomSize
        // 容器
        var text = ""
        // 開始產生正常字元 ...
        for index in stride(from: 0, to: textCount, by: 1) {
            switch startPoint {
            case .first:
                let index = content.index(content.startIndex, offsetBy: index)
                text += String(content[index])
            case .last:
                // reversed
                let index = content.index(content.endIndex, offsetBy: -(index + 1))
                text = String(content[index]) + text
            }
        }
        // 產生結果
        switch startPoint {
        case .first:
            self.text = text + randomText
        case .last:
            self.text = randomText + text
        }
        
    }

}



