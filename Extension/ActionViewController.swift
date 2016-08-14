//
//  ActionViewController.swift
//  Extension
//
//  Created by My Nguyen on 8/13/16.
//  Copyright © 2016 My Nguyen. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    @IBOutlet var script: UITextView!
    var pageTitle = ""
    var pageURL = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(done))

        // extensionContext allows control over how to interact with the parent app
        // inputItems is an array of data the parent app is sending to the extension
        // extract the first input item
        if let inputItem = extensionContext!.inputItems.first as? NSExtensionItem {
            // extract the first attachment from the array of attachments in the input item
            if let itemProvider = inputItem.attachments?.first as? NSItemProvider {
                // fetch an item from the item provider
                // note the closure which will execute asynchronously
                itemProvider.loadItemForTypeIdentifier(kUTTypePropertyList as String, options: nil) { [unowned self] (dict, error) in
                    // this closure will be called with the data received from the extension together with error
                    // data received is a dictionary
                    let itemDictionary = dict as! NSDictionary
                    // data is what got sent from JavaScript (Action.js) stored inside NSExtensionJavaScriptPreprocessingResultsKey
                    let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as! NSDictionary

                    // set the 2 properties to values from the javaScriptValues dictionary
                    self.pageTitle = javaScriptValues["title"] as! String
                    self.pageURL = javaScriptValues["URL"] as! String
                    // call dispatch_async() to set the view controller's title property on the main queue
                    // this is necessary because the closure being executed as a result of
                    // loadItemForTypeIdentifier() could be called on nay thread
                    dispatch_async(dispatch_get_main_queue()) {
                        self.title = self.pageTitle
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // this method will cause the extension to be closed and return any data passed in back to the parent app
    // this method is functionally the reverse of viewDidLoad()
    @IBAction func done() {
        // create a new NSExtensionItem object that will host our items
        let item = NSExtensionItem()
        // create a dictionary containing the key "customJavaScript" and the vaue of our script
        let customDictionary = ["customJavaScript": script.text]
        // put that dictionary into another dictionary with the key NSExtensionJavaScriptFinalizeArgumentKey
        let webDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: customDictionary]
        // wrap the big dictionary inside an ISItemProvider object with the type identifier kUTTypePropertyList
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        // place that NSItemProvider into our NSExtensionItem as its attachments
        item.attachments = [customJavaScript]
        // call completeRequestReturningItems(), returning the NSExtensionItem
        self.extensionContext!.completeRequestReturningItems(self.extensionContext!.inputItems, completionHandler: nil)
    }

}
