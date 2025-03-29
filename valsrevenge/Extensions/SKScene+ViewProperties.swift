//
//  SKScene+ViewProperties.swift
//  valsrevenge
//
//  Created by Tammy Coron on 7/4/20.
//  Copyright © 2020 Just Write Code LLC. All rights reserved.
//

import SpriteKit

extension SKScene {
  
  var viewTop: CGFloat {
    return convertPoint(fromView: CGPoint(x: 0.0, y: 0)).y
  }
  
  var viewBottom: CGFloat {
    guard let view = view else { return 0.0 }
    return convertPoint(fromView: CGPoint(x: 0.0,
                                          y: view.bounds.size.height)).y
  }
  
  var viewLeft: CGFloat {
    return convertPoint(fromView: CGPoint(x: 0, y: 0.0)).x
  }
  
  var viewRight: CGFloat {
    guard let view = view else { return 0.0 }
    return convertPoint(fromView: CGPoint(x: view.bounds.size.width,
                                          y: 0.0)).x
  }
  
  var insets: UIEdgeInsets {
    return UIApplication.shared.delegate?.window??.safeAreaInsets ?? .zero
  }
}
