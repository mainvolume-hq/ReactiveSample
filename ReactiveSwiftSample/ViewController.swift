//
//  ViewController.swift
//  ReactiveSwiftSample
//
//  Created by mainvolume on 6/8/16.
//  Copyright © 2016 mainvolume. All rights reserved.
//

import UIKit
import ReactiveKit
import ReactiveUIKit
import Foundation

class ViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var resultsTable: UITableView!
    
    private let vm = SearchPhotoVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindVM()
            
    }
    
    func bindVM() {
        
        self.vm.searchString.bindTo(self.searchTextField.rText)
        self.searchTextField.rText.bindTo(self.vm.searchString)
        self.vm.validated
            .map { $0 ? UIColor.blackColor() : UIColor.redColor() }
            .bindTo(self.searchTextField.rTextColor)
        
        
        
        self.vm.foundResults.bindTo(resultsTable) {
            
            indexPath, photos, tableView in
            
            let cell = tableView.dequeueReusableCellWithIdentifier("PhotoTVC", forIndexPath: indexPath)
                as! PhotoTVC
            
            let photo = photos[indexPath.row]
            cell.title.text = photo.title
            
            let qualityOfServiceClass = QOS_CLASS_BACKGROUND
            let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
            cell.photo.image = nil
            dispatch_async(backgroundQueue) {
                if let imageData = NSData(contentsOfURL: photo.url) {
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.photo.image = UIImage(data: imageData)
                    }
                }
            }
            return cell
        }
        
        self.vm.searching
            .map { !$0 }
            .bindTo(activityIndicator.rHidden)
        
        self.vm.searching
            .map { $0 ? CGFloat(0.5) : CGFloat(1.0) }
            .bindTo(resultsTable.rAlpha)
        
        self.vm.errorMsg.observe {
            [unowned self] error in
            
            let alertController = UIAlertController(title: "Something went wrong :-(",
                message: "\(error)", preferredStyle: .Alert)
            self.presentViewController(alertController, animated: true, completion: nil)
            let actionOk = UIAlertAction(title: "OK", style: .Default,
                handler: { action in alertController.dismissViewControllerAnimated(true, completion: nil) })
            
            alertController.addAction(actionOk)
        }.disposeIn(self.vm.td)
    }
    
    
}

