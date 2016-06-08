//
//  SearchPhotoViewModel.swift
//  ReactiveSwiftSample
//
//  Created by mainvolume on 6/8/16.
//  Copyright © 2016 mainvolume. All rights reserved.
//

import Foundation

// Represents a query that can be used to retrieve photos from the 500px API
struct PhotoQuery {
  var text = ""
  var creativeCommonsLicence = false
  var dateFilter = false
  var maxDate = NSDate()
  var minDate = NSDate()
}