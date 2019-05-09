//
//  HTTPHeaders.swift
//  Alamofire
//
//  Created by zhangzhonghai on 2019/5/8.
//  Copyright © 2019 ccclubs. All rights reserved.
//

import Foundation

public struct HTTPHeader {

    public let name: String
    public let value: String

    public init(name: String, value: String){
        self.name = name
        self.value = value
    }
}

extension HTTPHeader: CustomStringConvertible {

    public var description: String {
        return "\(name): \(value)"
    }
}

public struct HTTPHeaders {

    private var headers = [HTTPHeader]()

    public init() {}

    public init(_ headers: [HTTPHeader]) {
        self.init()
        headers.forEach({ update($0) })
    }

    public init(_ dictionary: [String: String]) {
        self.init()
        dictionary.forEach({ update(name: $0.key, value: $0.value) })
    }

    public mutating func add(name: String, value: String) {
        update(HTTPHeader(name: name, value: value))
    }

    public mutating func add(_ header: HTTPHeader) {
        update(header)
    }

    public mutating func update(name: String, value: String) {
        update(HTTPHeader(name: name, value: value))
    }

    public mutating func remove(name: String) {
        guard let index = headers.index(of: name) else { return }
        headers.remove(at: index)
    }

    public mutating func update(_ header: HTTPHeader) {
        guard let index = headers.index(of: header.name)  else {
            headers.append(header)
            return
        }
         headers.replaceSubrange(index...index, with: [header])
    }

    public mutating func sort() {
        headers.sort{ $0.name < $1.name }
    }

    public func sorted() -> HTTPHeaders {
        return HTTPHeaders(headers.sorted { $0.name < $1.name })
    }

    public func value(for name: String) -> String? {
        guard let index = headers.index(of: name) else { return nil }
        return headers[index].value
    }

    public subscript(_ name: String) -> String? {
        get {  return value(for: name) }
        set {
            if let value = newValue {
                update(name: name, value: value)
            }else {
                remove(name: name)
            }
        }
    }

    public var dictionary:[String: String] {
        let namesAndValues = headers.map { ($0.name,$0.value) }
        return Dictionary(namesAndValues, uniquingKeysWith: { (_,last) in last })
    }


}

extension HTTPHeaders {

    public static let `default`: HTTPHeaders = [.defaultAcceptEncoding,
                                                .defaultUserAgent,
                                                .defaultAcceptLanguage]
}




extension HTTPHeaders: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, String)...) {
        self.init()
        elements.forEach { update(name: $0.0, value: $0.1) }
    }
}

extension HTTPHeaders: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: HTTPHeader...) {
        self.init()
        elements.forEach { update($0) }
    }
}

extension HTTPHeaders: Sequence {
    public func makeIterator() -> IndexingIterator<Array<HTTPHeader>> {
        return headers.makeIterator()
    }
}

extension HTTPHeaders: Collection {
    public func index(after i: Int) -> Int {
        return headers.index(after: i)
    }

    public subscript(position: Int) -> HTTPHeader {
        return headers[position]
    }


    public var endIndex: Int {
        return headers.endIndex
    }


    public var startIndex: Int {
        return headers.startIndex
    }
}

extension HTTPHeaders: CustomStringConvertible {
    public var description: String {
        return headers.map { $0.description }.joined(separator: "\n")
    }
}

extension HTTPHeader {

    public static func acceptCharset(_ value: String) -> HTTPHeader {
        return HTTPHeader(name: "Accpet-Charset", value: value)
    }


    public static func acceptLanguage(_ value: String) -> HTTPHeader {
        return HTTPHeader(name: "Accept-Language", value: value)
    }

    public static func acceptEncoding(_ value: String) -> HTTPHeader {
        return HTTPHeader(name: "Accept-Encoding", value: value)
    }

    public static func authorization(_ value: String) -> HTTPHeader {
        return HTTPHeader(name: "Authorization", value: value)
    }

    public static func authorization(username:String ,password: String) -> HTTPHeader {
        let credential = Data("\(username):\(password)".utf8).base64EncodedString()
        return authorization("Basic \(credential)")
    }

    public static func authorization(bearerToken: String) -> HTTPHeader {
        return authorization("Bearer \(bearerToken)")
    }

    public static func contentDesposition(_ value: String) -> HTTPHeader {
        return HTTPHeader(name: "Content-Desposition", value: value)
    }

    public static func contentType(_ value: String) -> HTTPHeader {
        return HTTPHeader(name: "Content-Type", value: value)
    }

    public static func userAgent(_ value: String) -> HTTPHeader {
        return HTTPHeader(name: "User-Agent", value: value)
    }
}


extension HTTPHeader {

    public static let defaultAcceptEncoding: HTTPHeader = {
        let encodings: [String]
        if #available(iOS 11.0, macOS 10.13, tvOS 11.0, watchOS 4.0, *) {
            encodings = ["br","gzip","deflate"]
        }else {
            encodings = ["gzip","deflate"]
        }
        return acceptEncoding(encodings.qualityEncoded)
    }()

    public static let defaultAcceptLanguage: HTTPHeader = {
        return acceptLanguage(Locale.preferredLanguages.prefix(6).qualityEncoded)
    }()

    public static let defaultUserAgent: HTTPHeader = {

        let userAgent: String = {
            if let info = Bundle.main.infoDictionary {
                let executable = info[kCFBundleExecutableKey as String] as? String ?? "Unknown"
                let bundle = info[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
                let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
                let appBuild = info[kCFBundleVersionKey as String] as? String ?? "Unknown"

                let osNameVersion: String = {
                    let version = ProcessInfo.processInfo.operatingSystemVersion
                    let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"

                    let osName: String = {
                        #if os(iOS)
                        return "iOS"
                        #elseif os(watchOS)
                        return "watchOS"
                        #elseif os(tvOS)
                        return "tvOS"
                        #elseif os(macOS)
                        return "macOS"
                        #elseif os(Linux)
                        return "Linux"
                        #else
                        return "Unknown"
                        #endif
                    }()

                    return "\(osName) \(versionString)"
                }()

                let alamofireVersion: String = {
                    guard
                        let afInfo = Bundle(for: Session.self).infoDictionary,
                        let build = afInfo["CFBundleShortVersionString"]
                        else { return "Unknown" }

                    return "Alamofire/\(build)"
                }()

                return "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion)) \(alamofireVersion)"
            }

            return "Alamofire"
        }()

        return .userAgent(userAgent)
    }()
}


extension Collection where Element == String {

    var qualityEncoded: String {
        return enumerated().map { (index,encoding) in
            let quality = 1.0 - Double(index)*0.1
            return "\(encoding);q=\(quality)"
        }.joined(separator: ", ")
    }
}

extension Array where Element == HTTPHeader {

    func index(of name: String) -> Int? {
        let lowercasedName = name.lowercased()
        return firstIndex { lowercasedName == $0.name }
    }
}

extension URLRequest {
    public var headers: HTTPHeaders {
        get { return allHTTPHeaderFields.map(HTTPHeaders.init) ?? HTTPHeaders() }
        set { allHTTPHeaderFields = newValue.dictionary }
    }
}

extension HTTPURLResponse {
    public var headers: HTTPHeaders {
        return (allHeaderFields as? [String: String]).map(HTTPHeaders.init) ?? HTTPHeaders()
    }
}

extension URLSessionConfiguration {
    public var headers: HTTPHeaders {
        get { return (httpAdditionalHeaders as? [String: String]).map(HTTPHeaders.init) ?? HTTPHeaders()}
        set { httpAdditionalHeaders = newValue.dictionary }
    }
}
