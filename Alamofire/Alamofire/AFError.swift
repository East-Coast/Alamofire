//
//  AFError.swift
//  Alamofire
//
//  Created by zhangzhonghai on 2019/5/6.
//  Copyright © 2019 ccclubs. All rights reserved.
//

import Foundation

public enum AFError: Error {

    public enum ParameterEncodingFailureReason {
        case missingURL
        case jsonEncodingFailed(error:Error)
    }

    public enum ParameterEncoderFailureReason {

        public enum RequiredComponent {
            case url
            case httpMethod(rawValue: String)
        }

        case missingRequiredComponent(RequiredComponent)
        case encoderFailed(error:Error)
    }

    public enum MultipartEncodingFailureReason {
        case bodyPartURLInvalid(url: URL)
        case bodyPartFilenameInvalid(in: URL)
        case bodyPartFileNotReachable(at: URL)
        case bodyPartFileNotreachableWithError(atURL: URL, error: Error)
        case bodyPartFileIsDirectory(at: URL)
        case bodyPartFileSizeNotAvailable(at: URL)
        case bodyPartFileSizeQueryFailedWithError(forURL: URL, error:Error)
        case bodyPartInputStreamCreatingFailed(for: URL)
        
    }
}
