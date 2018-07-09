//
//  Common.swift
//  UserDefaultExample
//
//  Created by Marco Piersigilli on 06/02/18.
//  Copyright © 2018 studiopiersigilli.it. All rights reserved.
//

import Foundation

enum ResultType<T> {
    case Success(T)
    case Failure(e: Error)
}

// Error for unknown case
enum JSONDecodingError: Error, LocalizedError {
    case unknownError
    
    public var errorDescription: String? {
        switch self {
        case .unknownError:
            return NSLocalizedString("Unknown Error occured", comment: "")
        }
    }
}
