//
//  UILogger.swift
//  Bracelet One
//
//  Created by Laurence Wingo on 10/6/18.
//  Copyright © 2018 Cosmic Arrows, LLC. All rights reserved.
//

import Foundation
import UIKit

class UILogger {
    var textArea: UITextView!
    
    required init(out: UITextView) {
        DispatchQueue.main.async() {
            self.textArea = out
        }
        self.set()
    }
    
    func set(text: String? = "") {
        DispatchQueue.main.async {
            self.textArea.text = text
        }
    }
    
    func logEvent(message: String) {
        DispatchQueue.main.async {
            self.textArea.text = self.textArea.text + "=>" + message + "\n"
        }
    }
}
