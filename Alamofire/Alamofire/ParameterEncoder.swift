//
//  ParameterEncoder.swift
//  Alamofire
//
//  Created by zhangzhonghai on 2019/5/9.
//  Copyright © 2019 ccclubs. All rights reserved.
//

import Foundation

public protocol ParameterEncoder {

    func encoder<Parameters: Encodable>(_ parameters: Parameters? ,into request: URLRequest) throws -> URLRequest
}


open class JSONParameterEncoder: ParameterEncoder {

    public static var `default`: JSONParameterEncoder { return JSONParameterEncoder() }
    public static var prettyPrinted: JSONParameterEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return JSONParameterEncoder(encoder: encoder)
    }()


    public let encoder: JSONEncoder

    init(encoder:JSONEncoder = JSONEncoder()) {
        self.encoder = encoder
    }

    open func encoder<Parameters : Encodable>(_ parameters: Parameters?, into request: URLRequest) throws -> URLRequest {

        guard let parameters = parameters else { return request }
        var request = request
        do {
            let data = try encoder.encode(parameters)
            request.httpBody = data
            if request.headers["Content-Type"] == nil {
                request.headers.update(.contentType("application/json"))
            }
        } catch {
            throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
        }
        return request
    }
}


open class URLEncodedFromParameterEncoder {

    public enum Destination {
        case methodDependent
        case queryString
        case httpbody

        func encodesParametersInURL(_ method: HTTPMethod) -> Bool {
            switch self {
            case .methodDependent: return [.get,.head,.delete].contains(method)
            case .queryString: return true
            case .httpbody: return false
            }
        }
    }

    public let encoder: URLEncodedFromEncoder
    public let destination: Destination

    init(encoder: URLEncodedFromEncoder = URLEncodedFromEncoder(),
         destination: Destination = Destination.methodDependent) {

        self.encoder = encoder
        self.destination = destination
    }
}

public final class URLEncodedFromEncoder {

}
