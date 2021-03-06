//
//  ToolController.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public typealias ChangeNotifier = () -> ()

public final class ToolController {
    public var currentTool : Tool = NullTool() {
        willSet {
            currentTool.tearDown()
        }
        
        didSet {
            currentTool.setUp()
        }
    }
    
    public init() {
    
    }
    
    
    public func process(_ input: Input, atPosition: Vec2d, withModifier: Modifier) {
        currentTool.process(input, atPosition: atPosition, withModifier: withModifier)
    }
    
    public func cancel() {
        currentTool.cancel()
    }
}
