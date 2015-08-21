//
//  HandleGrabber.swift
//  ReformTools
//
//  Created by Laszlo Korte on 21.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformCore
import ReformStage

private enum State {
    case Idle
    case Searching(FormIdentifier, SearchingResult)
}

private enum SearchingResult {
    case None
    case Found(position: Vec2d, point: Handle, cycle: Int)
}

public class HandleGrabber {
    
    private var state : State = .Idle
    let handleUI : HandleUI

    let handleFinder : HandleFinder
    let radius : Double
    
    public init(stage : Stage, handleUI : HandleUI, radius: Double) {
        self.handleUI = handleUI
        self.handleFinder = HandleFinder(stage: stage)
        self.radius = radius
    }
    
    func refresh() {
        if case .Searching(let formId, let result) = state {
        
            let allPoints = handleFinder.getHandles(HandleQuery(filter: .Only(formId), location: .Any))
            
            if case .Found(_, let current, _) = result,
                let updated = handleFinder.getUpdatedHandle(current){
                    handleUI.state = .Active(updated, allPoints)
            } else {
                handleUI.state = .Show(allPoints)
            }
            
        } else {
            handleUI.state = .Hide
        }
    }
    
    func enable(formId: FormIdentifier) {
        if case .Searching(formId, _) = state {
            
        } else {
            state = .Searching(formId, .None)
        }
        refresh()
    }
    
    func disable() {
        state = .Idle
        refresh()
    }
    
    func searchAt(position: Vec2d) {
        if case .Searching(let formId, let oldResult) = state {
            
            switch oldResult {
            case .Found(_, _, let cycle):
                state = .Searching(formId, resultFor(formId, position: position, cycle: cycle))
            case .None:
                state = .Searching(formId, resultFor(formId, position: position, cycle: 0))
            }
        }
        
        refresh()
    }
    
    func cycle() {
        if case .Searching(let formId, .Found(let pos, _, let cycle)) = state {
            
            state =  .Searching(formId, resultFor(formId, position: pos, cycle: cycle+1))
        }
        
    }
    
    private func resultFor(formId : FormIdentifier, position: Vec2d, cycle: Int) -> SearchingResult {
        
        let points = handleFinder.getHandles(HandleQuery(filter: .Only(formId), location: .Near(position, distance: radius)))
        
        if points.count > 0 {
            return .Found(position: position, point: points[cycle%points.count], cycle: cycle)
        } else {
            return .None
        }
        
    }
    
    var current : Handle? {
        if case .Searching(_, .Found(_, let handle, _)) = state {
            return handle
        } else {
            return nil
        }
    }
    
    
}