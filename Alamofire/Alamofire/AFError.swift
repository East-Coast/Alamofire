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

        case outputStreamCreatingFailed(for: URL)
        case outputStreamFileAlreadyExists(at: URL)
        case outputStreamURLInvalid(url: URL)
        case outputStreamWriteFailed(error: Error)

        case inputStreamReadFailed(error: Error)
    }

    public enum ResponseValidationFailureReason {
        case dataFileNil
        case dataFileReadFailed(at: URL)
        case missingContentType(acceptableContentTypes: [String])
        case unacceptableContentTypes(acceptableContentTypes: [String], responseContentType: String)
        case unacceptableStatusCode(code: Int)
    }

    public enum ResponseSerializationFailureReason {
        case inputDataNilOrZeroLengh
        case inputFileNil
        case inputFileReadFailed(at: URL)
        case stringSerializationFailed(encodeing: String.Encoding)
        case jsonSerializationFailed(error: Error)
        case decodingFailed(error: Error)
        case invalidEmptResponse(type: String)
        case responseSerializerAddedAfterRequestFinished
    }

    public enum ServerTrustFailureReason {

        public struct Output {
            public let host: String
            public let trust: SecTrust
            public let status: OSStatus
            public let result: SecTrustResultType

            init(_ host: String, _ trust: SecTrust, _ status: OSStatus, _ result: SecTrustResultType) {
                self.host = host
                self.trust = trust
                self.status = status
                self.result = result
            }
        }

        case noRequiredEvaluator(host: String)
        case noCertificatesFound
        case noPublicKeysFound
        case policyApplicationFailed(trust: SecTrust, policy: SecPolicy, status: OSStatus)
        case settingAnchorCertificatesFailed(status: OSStatus, certificates: [SecCertificate])
        case revocationPolicyCreationFailed
        case defaultEvaluationFailed(output: Output)
        case hostValidationFailed(output: Output)
        //case revocationCheckFailed(output: Output, options: )
        case certificatesPinningFailed(host: String, trust: SecTrust, pinnedCertificates: [SecCertificate], serverCertificates: [SecCertificate])
        case publicKeyPinningFailed(host: String, trust: SecTrust, pinnedKeys: [SecKey], serverKeys: [SecKey])
    }

    case sessionDeinitialized
    case sessionInvaildated(error: Error)
    case explicitlyCancelled
    //case invalidURL(url: )
    case parameterEncodingFailed(reason: ParameterEncodingFailureReason)
    case parameterEncoderFailed(reason: ParameterEncoderFailureReason)
    case multipartEncodingFailed(reason: MultipartEncodingFailureReason)
    case requestAdaptationFailed(error: Error)
    case responseValidationFailed(reason: ResponseValidationFailureReason)
    case responseSerializationFailed(reason: ResponseSerializationFailureReason)
    case serverTrustEvaluationFailed(reason: ServerTrustFailureReason)
    case requestRetryFailed(retryError: Error, originalError: Error)
}


extension Error {

    public var asAFError: AFError? {
        return self as? AFError
    }
}

extension AFError {

    public var isSessionDeinitializedError: Bool {
        if case .sessionDeinitialized = self { return true }
        return false
    }

    public var isSessionInvaildatedError: Bool {
        if case .sessionInvaildated = self { return true }
        return false
    }

    public var isExplicitlyCancelledError: Bool{
        if case .explicitlyCancelled = self { return true }
        return false
    }
    // TODO: isInvalidURLError
//    public var isInvalidURLError: Bool {
//        if case .invalidURL = self { return true }
//        return false
//    }

    public var isParameterEncodingError: Bool {
        if case .parameterEncodingFailed = self { return true }
        return false
    }

    public var isParameterEncoderError: Bool {
        if case .parameterEncoderFailed = self { return true }
        return false
    }

    public var isMultipartEncodingError: Bool {
        if case .multipartEncodingFailed = self { return true }
        return false
    }

    public var isRequestAdaptationError: Bool {
        if case .requestAdaptationFailed = self { return true }
        return false
    }

    public var isResponseValidationError:Bool {
        if case .responseValidationFailed = self { return true }
        return false
    }

    public var isResponseSerializationError: Bool {
        if case .responseSerializationFailed = self { return true }
        return false
    }

    public var isServerTrsutEvaluationError: Bool {
        if case .serverTrustEvaluationFailed = self { return true }
        return false
    }

    public var isRequestRetryError: Bool {
        if case .requestRetryFailed = self { return true }
        return false
    }
}



extension AFError {

    //TODO: urlConvertible

    public var url: URL? {
        guard case .multipartEncodingFailed(let reason) = self else { return nil }
        return reason.url
    }

    public var underlyingError: Error? {
        switch self {
        case .multipartEncodingFailed(reason: let reason):
            return reason.underlyingError
        case .parameterEncoderFailed(reason: let reason):
            return reason.underlyingError
        case .parameterEncodingFailed(reason: let reason):
            return reason.underlyingError
        case .responseSerializationFailed(reason: let reason):
            return reason.underlyingError
        case .requestAdaptationFailed(error: let error):
            return error
        case .sessionInvaildated(error: let error):
            return error
        case .requestRetryFailed(retryError: let error, originalError: _):
            return error
        default:
            return nil
        }
    }

    public var acceptableContentTypes: [String]? {
        guard case .responseValidationFailed(let reason) = self else { return nil }
        return reason.acceptableContentTypes
    }

    public var responseContentType: String? {
        guard case .responseValidationFailed(let reason) = self else { return nil }
        return reason.responseContentType
    }

    public var responseCode: Int? {
        guard case .responseValidationFailed(let reason) = self else { return nil }
        return reason.responseCode
    }


    public var failedStringEncoding: String.Encoding? {
        guard case .responseSerializationFailed(let reason) = self else { return nil }
        return reason.failedStringEncoding
    }
}


extension AFError.ParameterEncodingFailureReason {

    var underlyingError: Error? {
        guard case .jsonEncodingFailed(let error) = self else { return nil }
        return error
    }
}

extension AFError.ParameterEncoderFailureReason {

    var underlyingError: Error? {
        guard case .encoderFailed(let error) = self else { return nil }
        return error
    }
}

extension AFError.MultipartEncodingFailureReason {

    var url: URL? {
        switch self {
        case .bodyPartFileIsDirectory(at: let url),
             .bodyPartFilenameInvalid(in: let url),
             .bodyPartFileNotReachable(at: let url),
             .bodyPartFileNotreachableWithError(atURL: let url, error: _),
             .bodyPartFileSizeNotAvailable(at: let url),
             .bodyPartFileSizeQueryFailedWithError(forURL: let url, error: _),
             .bodyPartInputStreamCreatingFailed(for: let url),
             .bodyPartURLInvalid(url: let url),
             .outputStreamURLInvalid(url: let url),
             .outputStreamCreatingFailed(for: let url),
             .outputStreamFileAlreadyExists(at: let url):
            return url
        default:
            return nil
        }
    }

    var underlyingError: Error? {
        switch self {
        case .bodyPartFileNotreachableWithError(atURL: _, error: let error),
             .bodyPartFileSizeQueryFailedWithError(forURL: _, error: let error),
             .inputStreamReadFailed(error: let error),
             .outputStreamWriteFailed(error: let error):
            return error
        default:
            return  nil
        }
    }
}

extension AFError.ResponseValidationFailureReason {

    var acceptableContentTypes: [String]? {
        switch self {
        case .missingContentType(let types),
             .unacceptableContentTypes(let types, _):
            return types
        default:
            return nil
        }
    }

    var responseContentType: String? {
        guard case .unacceptableContentTypes(_,let type) = self else { return nil }
        return type
    }

    var responseCode: Int? {
        guard case .unacceptableStatusCode(let code) = self else { return nil }
        return code
    }
}

extension AFError.ResponseSerializationFailureReason {

    var failedStringEncoding: String.Encoding? {
        guard case .stringSerializationFailed(let encoding) = self else { return nil }
        return encoding
    }

    var underlyingError: Error? {
        switch self {
        case .decodingFailed(error: let error),
             .jsonSerializationFailed(error: let error):
            return error
        default:
            return nil
        }
    }
}


extension AFError.ServerTrustFailureReason {

    //TODO: revocationCheckFailed
    var output: AFError.ServerTrustFailureReason.Output? {
        switch self {
        case .defaultEvaluationFailed(output: let output),
             .hostValidationFailed(output: let output)/*,
             .revocationCheckFailed(let output,_)*/:
            return output
        default:
            return nil
        }
    }
}


extension AFError.ParameterEncodingFailureReason {

    var localizationDescription: String {
        switch self {
        case .missingURL:
            return "URL request to encode was missing a URL"
        case .jsonEncodingFailed(error: let error):
            return "JSON could not be encoded ,because of error:\n \(error.localizedDescription)"
        }
    }
}

extension AFError.ParameterEncoderFailureReason {

    var localizationDescription:String {
        switch self {
        case .encoderFailed(error: let error):
            return "the underlying encoder failed with the error:\(error)"
        case .missingRequiredComponent(let componet):
            return "encoding failed due to a missing request component: \(componet)"
        }
    }
}

extension AFError.MultipartEncodingFailureReason {

    var localizationDescription: String {
        switch self {
        case .bodyPartFileIsDirectory(at: let url):
            return "the URL provided is a directory: \(url)"
        case .bodyPartFilenameInvalid(in: let url):
            return "the URL provided does not have a vaild filename: \(url)"
        case .bodyPartFileNotReachable(at: let url):
            return "the URL provided is not reachable: \(url)"
        case .bodyPartFileNotreachableWithError(atURL: let url, error: let error):
            return (
                "The system returned an error while checking the provided URL for " +
                "reachability.\nURL: \(url)\nError: \(error)"
            )
        case .bodyPartFileSizeNotAvailable(at: let url):
            return "Could not fetch the file size from the provided URL: \(url)"
        case .bodyPartFileSizeQueryFailedWithError(forURL: let url, error: let error):
            return (
                "The system returned an error while attempting to fetch the file size from the " +
                "provided URL.\nURL: \(url)\nError: \(error)"
            )
        case .bodyPartInputStreamCreatingFailed(for: let url):
            return "Failed to create an InputStream for the provided URL: \(url)"
        case .bodyPartURLInvalid(url: let url):
            return "The URL provided is not a file URL: \(url)"
        case .inputStreamReadFailed(error: let error):
            return "InputStream read failed with error: \(error)"
        case .outputStreamCreatingFailed(for: let url):
            return "Failed to create an OutputStream for URL: \(url)"
        case .outputStreamFileAlreadyExists(at: let url):
            return "A file already exists at the provided URL: \(url)"
        case .outputStreamURLInvalid(url: let url):
            return "The provided OutputStream URL is invalid: \(url)"
        case .outputStreamWriteFailed(error: let error):
            return "OutputStream write failed with error: \(error)"
        }
    }
}

