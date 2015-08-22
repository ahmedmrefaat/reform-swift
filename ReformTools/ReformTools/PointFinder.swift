//
//  PointFinder.swift
//  ReformTools
//
//  Created by Laszlo Korte on 18.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformCore
import ReformStage
import ReformExpression

enum LocationFilter : Equatable {
    case Any
    case Near(Vec2d, distance: Double)
}

func ==(lhs: LocationFilter, rhs: LocationFilter) -> Bool {
    switch (lhs, rhs) {
    case (.Any, .Any): return true
    case (.Near(let p1, let d1), .Near(let p2, let d2)): return p1==p2 && d1 == d2
    default: return false
    }
}

enum FormFilter : Equatable {
    case None
    case Any
    case Only(FormIdentifier)
    case Except(FormIdentifier)
}

func ==(lhs: FormFilter, rhs: FormFilter) -> Bool {
    switch (lhs, rhs) {
    case (.None, .None): return true
    case (.Any, .Any): return true
    case (.Only(let l), .Only(let r)): return l==r
    case (.Except(let l), .Except(let r)): return l==r
    default: return false
    }
}

struct PointQuery : Equatable {
    let filter: FormFilter
    let pointType: PointType
    let location : LocationFilter
}

func ==(lhs: PointQuery, rhs: PointQuery) -> Bool {
    return lhs.filter == rhs.filter && lhs.pointType == rhs.pointType && lhs.location == rhs.location
}

struct PointFinder {
    let stage : Stage
    
    func getUpdatedPoint(oldPoint: EntityPoint) -> EntityPoint? {
        for entity in stage.entities
            where entity.id == oldPoint.formId {
                for point in entity.points
                    where point.pointId == oldPoint.pointId {
                        return point
                }
        }
        
        return nil
    }
    
    func getUpdatedPoint(oldPoint: IntersectionSnapPoint) -> IntersectionSnapPoint? {
        for intersection in stage.intersections
            where intersection.point == oldPoint.point {
                return intersection
        }
        
        return nil
    }
    
    func getSnapPoints(query: PointQuery) -> [SnapPoint] {
        var result = [SnapPoint]()
        
        if case FormFilter.None = query.filter {
            return result
        }
        
        if (query.pointType.contains(.Form) || query.pointType.contains(.Glomp))  {
            for entity in stage.entities {
                if case .Except(entity.id) = query.filter {
                    continue
                }
                if case .Only(let id) = query.filter where id != entity.id {
                    continue
                }
                
                if query.pointType.contains(.Form) {
                    for p in entity.points {
                        if case .Near(let loc, let d) = query.location where (loc-p.position).length > d {
                            continue
                        }
                        result.append(p)
                    }
                }
                
                if case .Near(let loc, let d) = query.location where query.pointType.contains(.Glomp) {
                    if let (u, pos) = pointOn(segmentPath: entity.outline, closestTo: loc, maxDistance: d) {

                        result.append(GlompSnapPoint(position: pos, label: "Glomp", point: ReformCore.GlompPoint(formId: entity.id, lerp: Expression.Constant(.DoubleValue(value: u)))))
                    }
                }
            }
        }
        
        if case .Only = query.filter {
            return result
        }
        
        if query.pointType.contains(.Intersection) {
            for intersection in stage.intersections {
                if case .Except(let id) = query.filter where id == intersection.formIdA || id == intersection.formIdB {
                    continue
                }
                if case .Near(let loc, let d) = query.location where (loc-intersection.position).length > d {
                    continue
                }
                result.append(intersection)
            }
        }
        
        return result
    }
}