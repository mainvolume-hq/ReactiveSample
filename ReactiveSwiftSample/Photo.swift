//
//  SearchPhotoViewModel.swift
//  ReactiveSwiftSample
//
//  Created by mainvolume on 6/8/16.
//  Copyright © 2016 mainvolume. All rights reserved.
//

import Foundation
import ReactiveKit
typealias PhotoArray = [Photo]

// Represents a single photo as returned by the 500px API
struct Photo {
  let title: String
  let url: NSURL
  let date: NSDate
}
