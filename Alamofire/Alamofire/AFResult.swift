//
//  AFResult.swift
//  Alamofire
//
//  Created by zhangzhonghai on 2019/5/6.
//  Copyright © 2019 ccclubs. All rights reserved.
//

import Foundation

public typealias AFResult<T> = Result<T,Error>


extension AFResult {

    var value: Success? {
        guard case .success(let value) = self else { return nil }
        return value
    }

    var error: Failure? {
        guard case .failure(let error) = self else { return nil }
        return error
    }

    init(value:Success, error:Failure?) {
        if let error = error {
            self = .failure(error)
        }else {
            self = .success(value)
        }
    }

    func flatMap<T>( _ tarnsform: (Success) throws -> T) -> AFResult<T> {

        switch self {
        case .success(let value):
            do {
                return try .success(tarnsform(value))
            } catch {
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }

    func faltMapError<T:Error>(_ tansform: (Failure) throws -> T) -> AFResult<Success> {
        switch self {
        case .success(let value):
            return .success(value)
        case .failure(let error):
            do{
                return try .failure(tansform(error))
            } catch {
                return .failure(error)
            }
        }
    }
}
