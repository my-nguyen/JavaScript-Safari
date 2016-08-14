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

        /// in the text view, if you type a lot, the new text will be covered by the iOS keyboard.
        /// the followings fix that problem
        // get a reference to the default notification center
        let notificationCenter = NSNotificationCenter.defaultCenter()
        // addObserver takes 4 parameters
        // (1) the object that should receive notifications (self)
        // (2) the method that should be called
        // (3) the notification to receive
        //     UIKeyboardWillHideNotification is sent when the keyboard has finished hiding
        //     UIKeyboardWillChangeFrameNotification is shown when any keyboard state change happens,
        //     including showing and hiding, orientation, QuickType, etc
        // (4) the object to watch (nil means it doesn't matter)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIKeyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIKeyboardWillChangeFrameNotification, object: nil)

        // create a UIBarButtonItem and make it call done()
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
        extensionContext!.completeRequestReturningItems([item], completionHandler: nil)
    }

    func adjustForKeyboard(notification: NSNotification) {
        // extract the userInfo, which is an NSDictionary containing notification-specific information
        let userInfo = notification.userInfo!

        // with key UIKeyboardFrameEndUserInfoKey, the value is the frame of the keyboard after it has finished animating
        // typecast this value to an NSValue, then extract the CGRect from it, which is the keyboard frame
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        // convert the keyboard frame (CGRect) to the view's coordinates
        let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)

        // adjust the contentInset and scrollIndicatorInsets, to indent the edges of the text view so that
        // it appears to occupy less space
        if notification.name == UIKeyboardWillHideNotification {
            script.contentInset = UIEdgeInsetsZero
        } else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        script.scrollIndicatorInsets = script.contentInset

        // make the text view scroll so that the text entry cursor is visible
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }
}
