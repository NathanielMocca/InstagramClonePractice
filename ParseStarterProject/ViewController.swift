/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController{

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var changeSignupModeButton: UIButton!
    var signupMode = true
    
    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet weak var signupOrLogin: UIButton!
    
    //pop-up alert
    func createAlert(title: String,message: String ){
        
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "好", style: .default, handler: {(action) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //click SignUp or LogIn Button event
    @IBAction func SignupOrLogin(_ sender: Any) {
        
        //parseServer會幫我們辨識是否輸入格式合法,所以只要檢查是否傳入空字串即可
        if emailTextField.text == "" || passwordTextField.text == "" {
            
            createAlert(title: "錯誤的格式", message: "請輸入 Email 與 password")

        }else{
            //鎖定使用者螢幕（轉圈圈動畫）, 防止資料處理過程中被更改
            activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            //ignore interaction by user
            UIApplication.shared.beginIgnoringInteractionEvents()
                    
            if signupMode {
                
                //Do sign up
                let user = PFUser()
                user.username = emailTextField.text
                user.email = emailTextField.text
                user.password = passwordTextField.text
                
                user.signUpInBackground(block: { (success, error) in
                    //轉圈圈消失
                    self.activityIndicator.stopAnimating()
                    //allow interaction by user
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    if error != nil {
                        
                        let errorInNs = error as! NSError
                        let parseErrorMessage = errorInNs.userInfo["error"] as! String
                        
                        self.createAlert(title: "註冊錯誤了", message: parseErrorMessage)
                        
                    }else{
                        
                        //每個使用者都預設已追蹤自己的上傳
                        let following = PFObject(className: "Followers")
                        following["follower"] = PFUser.current()?.objectId
                        following["following"] = PFUser.current()?.objectId
                        following.saveInBackground()
                        
                        print("user signed up.")
                        self.performSegue(withIdentifier: "showUserTable", sender: self)

                    }
                })
            }else{
                
                //Do Log in 
                PFUser.logInWithUsername(inBackground: emailTextField.text!, password: passwordTextField.text!, block: { (user, error) in
                    
                    //轉圈圈消失
                    self.activityIndicator.stopAnimating()
                    //allow interaction by user
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    if error != nil {
                        
                        let errorInNs = error as! NSError
                        let parseErrorMessage = errorInNs.userInfo["error"] as! String
                        
                        self.createAlert(title: "登入錯誤了", message: parseErrorMessage)
                    }else{
                        
                        print("Logged in.")
                        self.performSegue(withIdentifier: "showUserTable", sender: self)
                        
                    }
                    
                })
                
            }
            
        }
        
        
    }
    @IBAction func changeSignupMode(_ sender: Any) {
        if signupMode {
            
            //change to login mode
            signupOrLogin.setTitle("登入", for: [])

            changeSignupModeButton.setTitle("註冊", for: [])
            
            messageLabel.text = "還沒有帳號嗎？"
            
            signupMode = false
            
        }else{
            
            //change to Signup mode
            
            signupOrLogin.setTitle("註冊", for: [])
            
            changeSignupModeButton.setTitle("登入", for: [])
            
            messageLabel.text = "已經有帳號了？"
            
            signupMode = true

        }

    }
    
    /*
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
 
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
        
    }
    */
    
    //摸其他地方會收鍵盤
    func onTouchGesture(){
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //當使用者已登入,直接跳到user table
        if PFUser.current() != nil {
            
            performSegue(withIdentifier: "showUserTable", sender: self)
            
        }
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.onTouchGesture))
        self.view.addGestureRecognizer(tap)

        UINavigationBar.appearance().tintColor = UIColor.white
        UITextField.appearance().tintColor = UIColor.lightGray
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
