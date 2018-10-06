

import UIKit
import CoreData
import Shimmer
import SCLAlertView
import AVFoundation
import AWSCognitoIdentityProvider

class LoginViewController: UIViewController, UITextFieldDelegate {
    // MARK: Properties
    var managedObjectContext: NSManagedObjectContext?
    var passwordItems: [KeychainPasswordItem] = []
    let createLoginButtonTag = 0
    let loginButtonTag = 1
    
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet var stackView: UIStackView!
    // MARK: - IBOutlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet weak var createInfoLabel: UILabel!
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var loginButtonFacebook: UIButton!
    @IBOutlet var loginButtonGoogle: UIButton!
    @IBOutlet var touchIDButton: UIButton!
    
    //MARK: - BiometricIDAuth
    let touchMe = BiometricIDAuth()
    
    //MARK: - Video Background
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    var paused: Bool = false
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        createVideo()
        //avPlayer.play()
        //1 Check the boolean value that corresponds to a NSUserDefaults value for the key 'hasLoginKey'
        let hasLogin = UserDefaults.standard.bool(forKey: "hasLoginKey")
        //2 if hasLogin equates to true then change the text of the login button and set its tag...
        if hasLogin{
            loginButton.setTitle("Login", for: .normal)
            loginButton.tag = loginButtonTag
            createInfoLabel.isHidden = true
        }else{
            loginButton.setTitle("Get Started", for: .normal)
            //emailTextField.isHidden = false
            loginButton.tag = createLoginButtonTag
            createInfoLabel.isHidden = true
        }
        //3 If there is a value within the key 'username' within NSUserdefaults then place it inside the username text field...
        if let storedUsername = UserDefaults.standard.value(forKey: "username") as? String {
            usernameTextField.text = storedUsername
        }
        
        touchIDButton.isHidden = !touchMe.canEvaluatePolicy()
        if !touchMe.canEvaluatePolicy() {
            keyboardHeightLayoutConstraint.constant = 0
            stackView.layoutIfNeeded()
        }
        
        switch touchMe.biometricType() {
        case .faceID:
            touchIDButton.setImage(UIImage.init(named: "FaceIcon"), for: .normal)
        default:
            touchIDButton.setImage(UIImage.init(named: "Touch-icon-lg"), for: .normal)
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if endFrameY >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 0.0
            } else {
                self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //paused = false
        let touchBool = touchMe.canEvaluatePolicy()
        if touchBool {
            //touchIDLoginAction((Any).self)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //avPlayer.pause()
        //paused = true
    }
    
    func createVideo() {
        let videoURL =  Bundle.main.url(forResource: "aafamily", withExtension: "mp4")
        avPlayer = AVPlayer.init(url: videoURL!)
        avPlayerLayer = AVPlayerLayer.init(player: avPlayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avPlayer.volume = 0
        avPlayer.actionAtItemEnd = .none
        avPlayerLayer.frame = view.layer.bounds
        //view.backgroundColor = UIColor.clear
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        let redOverlayView = UIView.init(frame: CGRect.init(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.width, height: view.frame.height))
        redOverlayView.backgroundColor = UIColor.red
        redOverlayView.alpha = 0.3
        view.layer.insertSublayer(redOverlayView.layer, at: 1)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
        avPlayer.play()
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: kCMTimeZero, completionHandler: nil)
    }
    
    func configureUI(){
        let view1 = FBShimmeringView.init()
        view1.backgroundColor = UIColor.clear
        view1.heightAnchor.constraint(equalToConstant: 60).isActive = true
        view1.widthAnchor.constraint(equalToConstant: 360).isActive = true
        
        //view2.widthAnchor.constraint(equalToConstant: stackView.arrangedSubviews[0].frame.width).isActive = true
        //view2.widthAnchor.constraint(equalToConstant: stackView.frame.width).isActive = true
        //view2.heightAnchor.constraint(equalToConstant: stackView.arrangedSubviews[0].frame.width).isActive = true
        //view2.heightAnchor.constraint(equalToConstant: stackView.frame.height).isActive = true
        //view2.heightAnchor.constraint(equalToConstant: 329).isActive = true
        //view2.widthAnchor.constraint(equalToConstant: 240).isActive = true
        
        stackView.insertArrangedSubview(view1, at: 0)
        let braceletOneLabel = UILabel.init(frame: CGRect.init(x: view1.frame.origin.x, y: view1.frame.origin.y, width: 340, height: 71))
        let braceletOneLogoImage = UIImage.init(named: "braceletOneLogo-2")
        let braceletOneLogoImageView = UIImageView.init(image: braceletOneLogoImage)
        braceletOneLogoImageView.contentMode = .scaleAspectFit
        braceletOneLabel.text = "Bracelet One"
        braceletOneLabel.font = UIFont.init(name: "Helvetica Neue", size: 60)
        braceletOneLabel.font = UIFont.systemFont(ofSize: 60, weight: .thin)
        braceletOneLabel.adjustsFontSizeToFitWidth = true
        braceletOneLabel.textColor = UIColor.white
        braceletOneLabel.textAlignment = .center
       
//        braceletOneLabel.layer.shadowColor = UIColor.black.cgColor
//        braceletOneLabel.layer.shadowRadius = 1.0
//        braceletOneLabel.layer.shadowOpacity = 1.0
//        braceletOneLabel.layer.shadowOffset = CGSize(width: 2, height: 0.2)
//        braceletOneLabel.layer.masksToBounds = false
    

        
        view1.contentView = braceletOneLabel
        view1.isShimmering = true
        view1.shimmeringSpeed = 120
        loginButton.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 20, bottom: 0, right: 20)
        loginButtonFacebook.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 20, bottom: 0, right: 20)
        loginButtonGoogle.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 20, bottom: 0, right: 20)
        usernameTextField.alpha = 0.5
        passwordTextField.alpha = 0.5
        emailTextField.alpha = 0.5
        
        usernameTextField.isHidden = true
        passwordTextField.isHidden = true
        emailTextField.isHidden = true
        createInfoLabel.isHidden = true
        
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @IBAction func touchIDLoginAction(_ sender: Any) {
        touchMe.authenticateUser { [weak self] message in
            if let message = message{
                //if the completion is not nil show an alert
                let appearance = SCLAlertView.SCLAppearance(
                    kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
                    kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
                    kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                    showCloseButton: true
                )
                let alert = SCLAlertView.init(appearance: appearance)
                alert.showError("Darn!", subTitle: message)
            } else {
                self?.performSegue(withIdentifier: "dismissLogin", sender: self)
            }
        }
    }
}

// MARK: - IBActions
extension LoginViewController {
    
    @IBAction func loginAction(sender: UIButton) {
        if usernameTextField.isHidden && passwordTextField.isHidden && emailTextField.isHidden {
            emailTextField.isHidden = false
            usernameTextField.isHidden = false
            passwordTextField.isHidden = false
            createInfoLabel.isHidden = false
            loginButton.setTitle("Create Account", for: .normal)
            return
        }
        guard let newAccountName = usernameTextField.text,
        let newPassword = passwordTextField.text,
            let newEmail = emailTextField.text,
            !newEmail.isEmpty,
        !newAccountName.isEmpty,
            !newPassword.isEmpty else {
                showLoginFailAlert()
                return
        }
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        if sender.tag == createLoginButtonTag {
            let name = UIDevice.current.name
            let user = User.init(name: name, username: newAccountName)
            
            //4
            let hasLoginKey = UserDefaults.standard.bool(forKey: "hasLoginKey")
            if !hasLoginKey && usernameTextField.hasText {
                UserDefaults.standard.setValue(usernameTextField.text, forKey: "username")
                //this stored the username in nsuserdefaults
            }
            //5
            do {
                //Since this is a new account, the following creates a new KeychainPasswordItem with the keychainconfiguration struct static service name as the service name and username as the account name to access it again from the keychain.
                let passwordItem = KeychainPasswordItem.init(service: KeychainConfiguration.serviceName, account: newAccountName, accessGroup: KeychainConfiguration.accessGroup)
                //Saving the password in keychain...
                try passwordItem.savePassword(newPassword)
            } catch {
                fatalError("Error updating keychain - \(error)")
            }
            //6
            //we're still inside the if statement based on the button's tag...
            //set the hasLogin variable to true to indicate that a password has beeen saved to the keychain
            UserDefaults.standard.setValue(true, forKey: "hasLoginKey")
            //set the login button tag to the loginButtonTag to show the text 'login' instead of 'create account'
            loginButton.tag = loginButtonTag
            //and finally dismiss the login view controller
            //++++++++++++++++++DO AWS STUFF HERE+++++++++++++++++++++++++
            let userpoolController = CognitoUserPoolController.sharedInstance
            userpoolController.signup(username: newAccountName, password: newPassword, emailAddress: newEmail) { (error: Error?, user: AWSCognitoIdentityUser?) in
                if let error = error {
                    self.displaySignupError(error: error as NSError, completion: nil)
                    return
                }
                guard let user = user else {
                    let error = NSError.init(domain: "com.cosmicarrows.Intellect", code: 1021, userInfo: ["_type":"Unknown Error", "message":"Missing User object"])
                    self.displaySignupError(error: error, completion: nil)
                    return
                }
                if user.confirmedStatus != AWSCognitoIdentityUserStatus.confirmed {
                    self.requestConfirmationCode(user)
                } else {
                    self.displaySuccessMessage()
                }
            }
            
        }else if sender.tag == loginButtonTag{
            //7
            if checkLogin(username: newAccountName, password: newPassword){
                let userpoolController = CognitoUserPoolController.sharedInstance
                userpoolController.login(username: newAccountName, password: newPassword) { (error) in
                    if let error = error {
                        self.displayLoginError(error: error as NSError)
                        return
                    }
                    self.displaySuccessMessage()
                    //performSegue(withIdentifier: "dismissLogin", sender: self)
                }
                //performSegue(withIdentifier: "dismissLogin", sender: self)
            }else{
                //8
                showLoginFailAlert()
            }
        }
    }
    
    fileprivate func displayLoginError(error: NSError) {
        let alertController = UIAlertController.init(title: error.userInfo["__type"] as? String, message: error.userInfo["message"] as? String, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    fileprivate func displaySuccessMessage() {
        let alertController = UIAlertController.init(title: "Success", message: "Login successful!", preferredStyle: .alert)
        let action = UIAlertAction.init(title: "Ok", style: .default) { [unowned self](action) in
            self.performSegue(withIdentifier: "dismissLogin", sender: self)
        }
        alertController.addAction(action)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    fileprivate func displaySignupError(error: NSError, completion:(() -> Void)?) {
        let alertController = UIAlertController.init(title: error.userInfo["_type"] as? String, message: error.userInfo["message"] as? String, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Ok", style: .default) { (action) in
            if let completion = completion {
                completion()
            }
        }
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    
    func checkLogin(username: String, password: String) -> Bool {
        guard username == UserDefaults.standard.value(forKey: "username") as? String else {
            return false
        }
        do {
            let passwordItem = KeychainPasswordItem.init(service: KeychainConfiguration.serviceName, account: username, accessGroup: KeychainConfiguration.accessGroup)
            let keychainPassword = try passwordItem.readPassword()
            return password == keychainPassword
        } catch {
            fatalError("Error reading password from keychain - \(error)")
        }
    }
    
    func showLoginFailAlert(){
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: true
        )
        let alert = SCLAlertView.init(appearance: appearance)
        alert.showError("Login Problem", subTitle: "Wrong username or password.")
    }
    
    func showSignUpFailAlert(){
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: true
        )
        let alert = SCLAlertView.init(appearance: appearance)
        alert.showError("Sign Up Problem", subTitle: "Please provide your username, a password, and a valid email address.")
    }
    
    func passwordHash(from username: String, password: String) -> String {
        let salt = "x4vV8bGgqqmQwgCoyXFQj+(o.nUNQhVP7ND"
        return "\(password).\(username).\(salt)"
    }
    
    fileprivate func requestConfirmationCode(_ user: AWSCognitoIdentityUser) {
        let alertController = UIAlertController.init(title: "Confirmation", message: "Please type the 6-digit confirmation code that has been sent to your email address.", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "######"
        }
        let okAction = UIAlertAction.init(title: "Ok", style: .default) { (action) in
            if let firstTextField = alertController.textFields?.first,
                let confirmationCode = firstTextField.text {
                let userpoolController = CognitoUserPoolController.sharedInstance
                userpoolController.confirmSignup(user: user, confirmationCode: confirmationCode, completion: { (error: Error?) in
                    if let error = error {
                        self.displaySignupError(error: error as NSError, completion: {
                            self.requestConfirmationCode(user)
                        })
                        return
                    }
                    self.displaySuccessMessage()
                })
            }
        }
        let resendAction = UIAlertAction.init(title: "Resend code", style: .default) { (action) in
            let userpoolController = CognitoUserPoolController.sharedInstance
            userpoolController.resendConfirmationCode(user: user, completion: { (error: Error?) in
                if let error = error {
                    self.displaySignupError(error: error as NSError, completion: {
                        self.requestConfirmationCode(user)
                    })
                    return
                }
                self.displayCodeResentMessage(user)
            })
        }
        alertController.addAction(okAction)
        alertController.addAction(resendAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    fileprivate func displayCodeResentMessage(_ user: AWSCognitoIdentityUser) {
        let alertController = UIAlertController.init(title: "Code Resent.", message: "A 6-digit confirmation code has been sent to your email address.", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Ok", style: .default) { (action) in
            self.requestConfirmationCode(user)
        }
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
