//
//  GradientLayer.swift
//  UIGradient
//
//  Created by Dinh Quang Hieu on 12/7/17.
//  Copyright © 2017 Dinh Quang Hieu. All rights reserved.
//

import UIKit

public enum GradientDirection {
    case topToBottom
    case bottomToTop
    case leftToRight
    case rightToLeft
    case topLeftToBottomRight
    case topRightToBottomLeft
    case bottomLeftToTopRight
    case bottomRightToTopLeft
    case custom(Int)
}

open class GradientLayer: CAGradientLayer {

    var direction: GradientDirection = .bottomLeftToTopRight

    public init(direction: GradientDirection, colors: [UIColor], cornerRadius: CGFloat = 0, locations: [Double]? = nil) {
        super.init()
        self.direction = direction
        self.needsDisplayOnBoundsChange = true
        self.colors = colors.map { $0.cgColor as Any }
        let (startPoint, endPoint) = UIGradientHelper.getStartAndEndPointsOf(direction)
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.cornerRadius = cornerRadius
        self.locations = locations?.map { NSNumber(value: $0) }
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init()
    }
    
    public final func clone() -> GradientLayer {
        if let colors = self.colors {
            return GradientLayer(direction: self.direction, colors: colors.map { UIColor(cgColor: ($0 as! CGColor)) }, cornerRadius: self.cornerRadius, locations: self.locations?.map { $0.doubleValue } )
        }
        return GradientLayer(direction: self.direction, colors: [], cornerRadius: self.cornerRadius, locations: self.locations?.map { $0.doubleValue })
    }
}

public extension GradientLayer {
    
    static var purple: GradientLayer {
        return GradientLayer(direction: .leftToRight , colors: [UIColor.hex("FB28CE"), UIColor.hex("A039E7")])
    }
    
    static var green: GradientLayer {
        return GradientLayer(direction: .leftToRight , colors: [UIColor.hex("00B09B"), UIColor.hex("96C93D")])
    }
    
    static var blue: GradientLayer {
        return GradientLayer(direction: .leftToRight , colors: [UIColor.hex("537EFF"), UIColor.hex("2A49CA")])
    }
    
    static var pink: GradientLayer {
        return GradientLayer(direction: .leftToRight , colors: [UIColor.hex("F953C6"), UIColor.hex("B91D73")])
    }
    
    static func getGradientForIndex(_ index: Int) -> GradientLayer {
        switch index % 10 {
        case 0,4,8: return GradientLayer.blue
        case 1,5,9: return GradientLayer.purple
        case 2,6: return GradientLayer.pink
        case 3,7: return GradientLayer.green
        default:
            return GradientLayer.purple
        }
    }
}
