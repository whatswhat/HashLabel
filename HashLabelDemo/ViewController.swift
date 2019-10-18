//
//  ViewController.swift
//  HashLabelDemo
//
//  Created by Diego on 2019/8/27.
//  Copyright © 2019 whatzwhat. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    @IBOutlet weak var segmented: UISegmentedControl!
    
    @IBOutlet weak var label: HashLabel!
    
    @IBOutlet weak var field: UITextField!
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var sliderLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sliderAction()
        // 10 / 18 新增, 白名單
        label.whitelist = [".", ",", "%"]
    }
    
    private func getMode() -> HashLabel.Mode {
        switch segmented.selectedSegmentIndex {
        case 1:
            return .no
        case 2:
            return .en
        case 3:
            return .zh
        default:
            return .default
        }
    }

    @IBAction func button(_ sender: UIButton) {
        guard let text = field.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        label.setText(text, duration: Double(slider.value), mode: getMode())
    }
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        field.endEditing(true)
    }
    
    @IBAction func point(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            label.startPoint = .first
        default:
            label.startPoint = .last
        }
    }
    
    @IBAction func sliderChange(_ sender: UISlider) {
        sliderAction()
    }
    
    private func sliderAction() {
        let result = String(format: "%.1f", Double(slider.value))
        sliderLabel.text = "\(result) 秒"
    }
    

}

