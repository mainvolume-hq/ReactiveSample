//
//  SearchPhotoViewModel.swift
//  ReactiveSwiftSample
//
//  Created by mainvolume on 6/8/16.
//  Copyright © 2016 mainvolume. All rights reserved.
//

import Foundation

// Describes the various errors that can occur when querying the 500px API
enum PhotoSearchError: ErrorType {
  case RequestError
  case ParseError
  case MalformedRequest
}