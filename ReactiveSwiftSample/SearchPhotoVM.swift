//
//  SearchPhotoViewModel.swift
//  ReactiveSwiftSample
//
//  Created by mainvolume on 6/8/16.
//  Copyright © 2016 mainvolume. All rights reserved.
//

import Foundation
import ReactiveKit
import ReactiveUIKit

class SearchPhotoVM {
    
    let searchString = Property<String?>("")
    let validated = Property<Bool>(false)
    let searching = Property<Bool>(false)
    
    let td = DisposeBag()
    
    private let searchManager: PhotoSearch = {
        let apiKey = NSBundle.mainBundle().objectForInfoDictionaryKey("apiKey") as! String
        return PhotoSearch(key: apiKey)
    }()
    let foundResults =  CollectionProperty<[Photo]>([])
    let errorMsg : PushStream<String> = PushStream<String>()
    
    
    
    
    init() {
        searchString.value = "Sina"
        
        searchString
            .map { $0?.characters.count > 3}
            .bindTo(validated)
        
        searchString
            .filter { $0?.characters.count > 3}
            .sample (0.5, on: Queue.main)
            .observe {
                [unowned self] text in
                self.performSearch(text)
            }.disposeIn(td)
    }
    
    func performSearch(text: StreamEvent<String?>) {
        
        var q = PhotoQuery()
        q.text = searchString.value ?? ""
        self.searching.value = true
        searchManager.findPhotos(q) {
            [unowned self] results in
            self.searching.value = false
            switch results {
            case .Success(let photos):
                print("500px API returned \(photos.count) photos")
                self.foundResults.removeAll()
                self.foundResults.insertContentsOf(photos, at: 0)
            case .Error:
                    self.errorMsg.next("There seem to be a problem fetching pictures!")
            }
        }
    }
 
    deinit {
        td.dispose()
    }
}