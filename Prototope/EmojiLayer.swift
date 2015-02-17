//
//  EmojiLayer.swift
//  Prototope
//
//  Created by Saniul Ahmed on 16/02/2015.
//  Copyright (c) 2015 Khan Academy. All rights reserved.
//

import Foundation

public class EmojiLayer: Layer {
    public var emoji: Character {
        return Character(label.text!)
    }
    
    public var fontSize: Double = 64 {
        didSet {
            updateFont()
            updateSizePreservingOrigin()
        }
    }
    
    private func updateFont() {
        label.font = UIFont(name: "AppleColorEmoji", size: CGFloat(fontSize))!
        updateSizePreservingOrigin()
    }
    
    private func updateSizePreservingOrigin() {
        label.sizeToFit()
    }
    
    private var label: UILabel {
        return self.view as! UILabel
    }
    
    public init(parent: Layer? = Layer.root, name: String? = nil, emoji: Character) {
        super.init(parent: parent, name: name, viewClass: UILabel.self)
        self.label.text = String(emoji)
        updateFont()
    }
}