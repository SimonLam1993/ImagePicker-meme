//
//  ViewController.swift
//  ImagePicker
//
//  Created by simon on 7/12/16.
//  Copyright © 2016 simon. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

  
    @IBOutlet weak var share: UIButton!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var camera: UIBarButtonItem!

    
    let imagePicker = UIImagePickerController()
    
    let topTextDefaultString = "TOP"
    let bottomTextDefaultString = "BOTTOM"
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : 2
    ]
    
    @IBAction func pickAnImage(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }
  
    
    @IBAction func share(sender: AnyObject) {
        //genearate memed image
        var image: UIImage = generateMemedImage()
        //define instance of ActivityViewController
        let activityController = UIActivityViewController(activityItems:
            [image], applicationActivities: nil)
        
        activityController.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[AnyObject]?, error: NSError?) in
            
            // Return if cancelled
            if (!completed) {
                return
            }
            
            self.save()
            self.dismissViewControllerAnimated(true, completion: nil)
    }
        //pass and present the ActivityViewController
        presentViewController(activityController, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imagePicker.delegate = self
        camera.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        //text editor properties
        topText.delegate = self
        bottomText.delegate = self
        topText.text = topTextDefaultString
        bottomText.text = bottomTextDefaultString
        topText.textAlignment = .Center
        bottomText.textAlignment = .Center
        topText.defaultTextAttributes = memeTextAttributes
        bottomText.defaultTextAttributes = memeTextAttributes
        
        // Subscribe to keyboard notifications to allow the view to raise when necessary
        self.subscribeToKeyboardNotifications()
        
        // Disable "share" button
        share.enabled = false
        
        
    }
    

    //image display methods
    
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.contentMode = .ScaleAspectFit
            imagePickerView.image = pickedImage
            //Make share button visible now that there is an image displayed
            share.enabled = true
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        print ("did cancel called")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    //Text field methods
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text == bottomTextDefaultString || textField.text == topTextDefaultString{
            textField.text = nil
        }
    }
    
    // to end editing when user touches other part of screen
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }

    //KEYBOARd
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Subscribe to keyboard notifications to allow the view to raise when necessary
        self.subscribeToKeyboardNotifications()
        camera.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomText.isFirstResponder(){
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification){
        if bottomText.isFirstResponder(){
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
        
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
    }
    
    func save() {
        //Create the meme
        let meme = Meme( topText: topText.text!, bottomText: bottomText.text!, image:
            imagePickerView.image!, memeImage: generateMemedImage())
    }
    
    func generateMemedImage() -> UIImage
    {
        //Hide toolbar and navbar
        toolbar.hidden = true
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Show toolbar and navbar
        toolbar.hidden = false
        
        return memedImage
    }
    
    struct Meme {
        var topText: String!
        var bottomText: String!
        var image: UIImage!
        var memeImage: UIImage!
    }
}

