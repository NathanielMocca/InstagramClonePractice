//
//  PostViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Mocca Yang on 2017/6/3.
//  Copyright © 2017年 Parse. All rights reserved.
//

import UIKit
import Parse

class PostViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {

    var activityIndicator = UIActivityIndicatorView()
    
    
    @IBOutlet weak var imageToPost: UIImageView!

    @IBAction func chooseAnImageToUpload(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
        
    }

    //當imagePickerController取得照片後,將照片放到imageView
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageToPost.image = image
            
        }
        
        //關閉imagePickerController
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //pop-up alert
    func createAlert(title: String,message: String ){
        
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "好", style: .default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }

    @IBAction func postImage(_ sender: Any) {
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        //ignore interaction by user
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let post = PFObject(className: "Posts")
        
        post["message"] = messageTextbox.text
        post["userId"] = PFUser.current()?.objectId!
        
        //let imageData = UIImagePNGRepresentation(imageToPost.image!)
        let imageData = UIImageJPEGRepresentation(imageToPost.image!, 1)
        //save on parse by parsefile
        let imageFile = PFFile(name: "image.jpeg", data: imageData!)
        
        post["imageFile"] = imageFile
        
        post.saveInBackground { (Success, error) in
            
            //轉圈圈消失
            self.activityIndicator.stopAnimating()
            //allow interaction by user
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if error != nil {
                self.createAlert(title: "相片上傳錯誤", message: "請稍後再試")
            }else{
                self.createAlert(title: "相片已上傳", message: "上傳成功")
                self.messageTextbox.text = ""
                self.imageToPost.image = UIImage(named: "default-person")
            }
            
        }
        
    }
    
    
    @IBOutlet weak var messageTextbox: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let titleView = UIImageView(image: UIImage(named: "Instagram Text Logo_s"))
        titleView.contentMode = UIViewContentMode.scaleAspectFit
        self.navigationItem.titleView = titleView
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
