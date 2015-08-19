//
//  SelectionTool.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformStage

public class SelectionTool : Tool {
    enum State
    {
        case Idle
        case Pressed(entity: Entity?, cycle: Int)
    }
    
    var state : State = .Idle {
        didSet {
            update(state)
        }
    }
    
    let stage : Stage
    let selection : EntitySelection
    let selectionUI : SelectionUI
    
    let entityFinder : EntityFinder
        
    public init(stage: Stage, selection: EntitySelection, selectionUI: SelectionUI) {
        self.stage = stage
        self.selection = selection
        self.selectionUI = selectionUI
        
        self.entityFinder = EntityFinder(stage: stage)
    }
    
    public func setUp() {
        selectionUI.state = .Show(selection)
    }
    
    public func tearDown() {
        selectionUI.state = .Hide
    }
    
    public func refresh() {
    }
    
    public func focusChange() {
    }
    
    public func cancel() {
        switch state {
        case .Idle:
            selection.selected = nil
        case .Pressed:
            state = .Idle
        }
    }
    
    public func process(input: Input, atPosition position: Vec2d, withModifier: Modifier) {
        switch input {
        case .Move:
            break
        case .Press:
            let entities = entitiesNear(position)

            if let previous = selection.selected where previous.hitArea.contains(position), let index = entities.indexOf(previous) {
                state = .Pressed(entity: previous, cycle: index)
            } else {
                state = .Pressed(entity: entities.first, cycle: 0)
            }
            break
        case .Release:
            state = .Idle
            break
        case .Cycle:
            switch state {
            case .Pressed(_, let cycle):
                let entities = entitiesNear(position)
                if entities.count > 0 {
                    state = .Pressed(entity: entities[(cycle+1)%entities.count], cycle: cycle+1)
                }
                break
            case .Idle:
                break
            }
            break
        case .Toggle, .ModifierChange:
            break

        }
    }
    
    private func entitiesNear(position: Vec2d) -> [Entity] {
        let query = EntityQuery(filter: .Any, location: .Near(position, distance: 0))
        return entityFinder.getEntities(query)
    }
    
    private func update(state: State) {
        switch state {
        case .Pressed(let entity, _):
            selection.selected = entity

            break
        case .Idle:
            break
        }
    }
}