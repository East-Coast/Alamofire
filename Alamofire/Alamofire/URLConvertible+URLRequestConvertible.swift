//
//  URLConvertible.swift
//  Alamofire
//
//  Created by zhangzhonghai on 2019/5/8.
//  Copyright © 2019 ccclubs. All rights reserved.
//

import Foundation

public protocol URLCovertible {

    func asURL() throws -> URL
}

extension String: URLCovertible {

    public func asURL() throws -> URL {
        guard let url = URL(string: self) else { throw AFError.invalidURL(url: self) }
        return url
    }
}

extension URL: URLCovertible {

    public func asURL() throws -> URL { return self }
}

extension URLComponents: URLCovertible {

    public func asURL() throws -> URL {
        guard let url = url else { throw AFError.invalidURL(url: self) }
        return url
    }
}

public protocol URLRequestConvertible {

    func asURLRequest() throws -> URLRequest
}

extension URLRequestConvertible {

    public var urlRequest: URLRequest? {
        return try? asURLRequest()
    }
}

extension URLRequest: URLRequestConvertible {

    public func asURLRequest() throws -> URLRequest {
        return self
    }
}

extension URLRequest {

    public init(url: URLCovertible, method: HTTPMethod, headers: HTTPHeaders? = nil) throws {
        let url = try url.asURL()
        self.init(url: url)
        httpMethod = method.rawValue
        allHTTPHeaderFields = headers?.dictionary
    }
}
