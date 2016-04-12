//
//  ViewController.swift
//  MemeMe
//
//  Created by Noah Anderson on 4/10/16.
//  Copyright © 2016 Noah Anderson. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{

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
    var keyboardHeightY:CGFloat?
    var ourMeme:Meme?
    override func viewDidLoad() {
        super.viewDidLoad()
        ourMeme = Meme()
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
            NSStrokeWidthAttributeName : -3.0
        ]
        setTextFieldProperties(topTextField, attributes: memeTextAttributes, alignment: NSTextAlignment.Center)
        setTextFieldProperties(bottomTextField, attributes: memeTextAttributes, alignment: NSTextAlignment.Center)
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

    override func prefersStatusBarHidden() -> Bool {
        return true     // status bar should be hidden
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
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
        if bottomTextField.isFirstResponder() {
            self.view.frame.origin.y = getKeyBoardHeight(notification) * -1
        }
    }
    
    func keyboardWillHide(notification : NSNotification){
        if bottomTextField.isFirstResponder() {
            self.view.frame.origin.y = 0
        }
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
            memeImageView.contentMode = .ScaleAspectFit
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
        ourMeme = Meme(tf1: topTextField.text, tf2: bottomTextField.text, img: memeImageView.image, imgMemed: generateMemedImage())
        var objectsToShare = [AnyObject]()
        objectsToShare.append((ourMeme?.imgMemed)!)
        let shareController = UIActivityViewController(activityItems: objectsToShare,applicationActivities: nil)
        self.presentViewController(shareController, animated: true, completion: nil)
        shareController.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[AnyObject]?, error: NSError?) in
            if (!completed) {
                return
            }
            self.saveMeme()
        }
    }

    @IBAction func cancelMeme(sender: UIBarButtonItem) {
        if memeImageView.image != nil{
            memeImageView.image = nil
        }
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        shareButton.enabled = false
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
    
    func setTextFieldProperties (textfield: UITextField, attributes: [String: AnyObject], alignment: NSTextAlignment){
        textfield.defaultTextAttributes = attributes
        textfield.textAlignment = alignment
    }
    
    func saveMeme(){
//        let todaysDate = NSDate()
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "yyyyMMdd_HH:mm:ss"
//        let dateString = dateFormatter.stringFromDate(todaysDate)
//        let imagePath = fileInDocumentsDirectory("Meme_\(dateString)")
//        print("saving to...")
//        print(imagePath)
//        let pngImageData = UIImagePNGRepresentation((ourMeme?.imgMemed)!)
//        let result = pngImageData!.writeToFile(imagePath, atomically: true)
        UIImageWriteToSavedPhotosAlbum((ourMeme?.imgMemed)!, nil, nil, nil)
    }
    
    func getDocumentsURL() -> NSURL {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        return documentsURL
    }
    
    func fileInDocumentsDirectory(filename: String) -> String {
        
        let fileURL = getDocumentsURL().URLByAppendingPathComponent(filename)
        return fileURL.path!
        
    }
    
}