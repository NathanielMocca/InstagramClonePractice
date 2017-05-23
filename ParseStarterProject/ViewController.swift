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

class ViewController: UIViewController {

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
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
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
                        
                        print("user signed up.")
                        self.createAlert(title: "註冊成功", message: "請登入")
                        //切換至登入模式
                        self.changeSignupMode(self)
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
                        
                    }
                    
                })
                
            }
            
        }
        
        
    }
    @IBAction func changeSignupMode(_ sender: Any) {
        if signupMode {
            
            //change to login mode
            signupOrLogin.setTitle("Log in", for: [])

            changeSignupModeButton.setTitle("Sign up", for: [])
            
            messageLabel.text = "Don't have an account?"
            
            signupMode = false
            
        }else{
            
            //change to Signup mode
            
            signupOrLogin.setTitle("Sign up", for: [])
            
            changeSignupModeButton.setTitle("Log in", for: [])
            
            messageLabel.text = "Already have an account?"
            
            signupMode = true

        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
