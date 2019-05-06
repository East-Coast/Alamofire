//
//  AlamofireExtended.swift
//  Alamofire
//
//  Created by zhangzhonghai on 2019/5/6.
//  Copyright © 2019 ccclubs. All rights reserved.
//

public struct AlamofireExtension<ExtendedType> {
    let type: ExtendedType

    init(_ type:ExtendedType) {
        self.type = type
    }
}

public protocol AlamofireExtended {
    associatedtype ExtendedType

    static var af: AlamofireExtension<ExtendedType>.Type { get set }
    var af: AlamofireExtension<ExtendedType> { get set }
}

public extension AlamofireExtended {

    static var af: AlamofireExtension<Self>.Type {
        get { return AlamofireExtension<Self>.self }
        set {}
    }

    var af: AlamofireExtension<Self> {
        get { return AlamofireExtension(self) }
        set { }
    }
}
