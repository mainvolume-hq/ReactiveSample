//
//  SearchPhotoViewModel.swift
//  ReactiveSwiftSample
//
//  Created by mainvolume on 6/8/16.
//  Copyright © 2016 mainvolume. All rights reserved.
//

import Foundation

// Describes the result of an asynchronous query
enum Result<T> {
  case Success(T)
  case Error(ErrorType)
}