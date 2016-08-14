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

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

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
                    print(javaScriptValues)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequestReturningItems(self.extensionContext!.inputItems, completionHandler: nil)
    }

}
