//
//  ViewController.swift
//  MemeMe
//
//  Created by Noah Anderson on 4/10/16.
//  Copyright © 2016 Noah Anderson. All rights reserved.
//

import UIKit

class ViewController: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{

    @IBOutlet var shareButton: UIBarButtonItem!
    @IBOutlet var albumButton: UIBarButtonItem!
    @IBOutlet var cameraButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var memeImageView: UIImageView!
    @IBOutlet var topTextField: UITextField!
    @IBOutlet var bottomTextField: UITextField!
    @IBOutlet var topToolBar: UIToolbar!
    @IBOutlet var bottomToolBar: UIToolbar!
    
    let imagePicker = UIImagePickerController()
    var memedImage:UIImage?
    var keyboardHeightY:CGFloat?
    override func viewDidLoad() {
        super.viewDidLoad()
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            cameraButton.enabled = false
        }
        imagePicker.delegate = self
        topTextField.delegate = self
        bottomTextField.delegate = self
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : 3.0
        ]
        
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = NSTextAlignment.Center
        bottomTextField.textAlignment = NSTextAlignment.Center
        topTextField.textColor = UIColor.whiteColor()
        bottomTextField.textColor = UIColor.whiteColor()
        shareButton.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unSubscribeFromKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == topTextField && topTextField.text == "TOP" {
            topTextField.text = ""
        }
        if textField == bottomTextField && bottomTextField.text == "BOTTOM" {
            bottomTextField.text = ""
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func getKeyBoardHeight(notification : NSNotification) -> CGFloat{
        let userinfo = notification.userInfo
        let keyboardSize = userinfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func keyboardWillShow(notification : NSNotification){
        self.view.frame.origin.y -= getKeyBoardHeight(notification)
    }
    
    func keyboardWillHide(notification : NSNotification){
        self.view.frame.origin.y += getKeyBoardHeight(notification)
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unSubscribeFromKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillShowNotification, object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillHideNotification, object:nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            memeImageView.contentMode = .ScaleAspectFill
            memeImageView.image = pickedImage
            shareButton.enabled = true
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func chooseImage(sender: UIBarButtonItem) {
        imagePicker.allowsEditing = false
        if sender == albumButton {
            imagePicker.sourceType = .PhotoLibrary
        }
        else if sender == cameraButton {
            imagePicker.sourceType = .Camera
        }
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shareMeme(sender: UIBarButtonItem) {
        //let textToShare = "Meme Me 1.0 | Noah J Anderson"
        memedImage = generateMemedImage()
        let imageToShare : UIImage = memedImage!
        var objectsToShare = [AnyObject]()
        objectsToShare.append(imageToShare)
        let shareController = UIActivityViewController(activityItems: objectsToShare,applicationActivities: nil)
        self.presentViewController(shareController, animated: true, completion: nil)
    }

    @IBAction func cancelMeme(sender: UIBarButtonItem) {
        if memeImageView.image != nil{
            memeImageView.image = nil
        }
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        shareButton.enabled = false
        memedImage = nil
    }
    
    func generateMemedImage() -> UIImage {
        topToolBar.hidden = true
        bottomToolBar.hidden = true
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        topToolBar.hidden = false
        bottomToolBar.hidden = false
        return memedImage
    }
}