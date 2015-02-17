//
//  EmojiLayerBridge.swift
//  Prototope
//
//  Created by Saniul Ahmed on 16/02/2015.
//  Copyright (c) 2015 Khan Academy. All rights reserved.
//

import Foundation
import Prototope
import JavaScriptCore

@objc public protocol EmojiLayerJSExport: JSExport {
    var emoji: String { get }
    var fontSize: Double { get set }
}


@objc public class EmojiLayerBridge: LayerBridge, EmojiLayerJSExport, BridgeType {
    var emojiLayer: EmojiLayer { return layer as! EmojiLayer }
    
    public override class func addToContext(context: JSContext) {
        context.setObject(self, forKeyedSubscript: "EmojiLayer")
    }
    
    public required init?(args: NSDictionary) {
        let parentLayer = (args["parent"] as! LayerBridge?)?.layer
        let emoji = (args["emoji"] as! String)
        
        let emojiLayer = EmojiLayer(parent: parentLayer, name: (args["name"] as! String?), emoji: Character(emoji))
        super.init(emojiLayer)
    }
    
    public var emoji: String {
        get { return String(emojiLayer.emoji) }
    }
    
    public var fontSize: Double {
        get { return emojiLayer.fontSize }
        set { emojiLayer.fontSize = newValue }
    }
}