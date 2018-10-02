

import UIKit
import CoreData
import Shimmer
import SCLAlertView

class LoginViewController: UIViewController {
    
    // MARK: Properties
    var managedObjectContext: NSManagedObjectContext?
    var passwordItems: [KeychainPasswordItem] = []
    let createLoginButtonTag = 0
    let loginButtonTag = 1
    
    
    @IBOutlet var stackView: UIStackView!
    // MARK: - IBOutlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var createInfoLabel: UILabel!
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var loginButtonFacebook: UIButton!
    @IBOutlet var loginButtonGoogle: UIButton!
    @IBOutlet var touchIDButton: UIButton!
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        //1 Check the boolean value that corresponds to a NSUserDefaults value for the key 'hasLoginKey'
        let hasLogin = UserDefaults.standard.bool(forKey: "hasLoginKey")
        //2 if hasLogin equates to true then change the text of the login button and set its tag...
        if hasLogin{
            loginButton.setTitle("Login", for: .normal)
            loginButton.tag = loginButtonTag
            createInfoLabel.isHidden = true
        }else{
            loginButton.setTitle("Create Account", for: .normal)
            loginButton.tag = createLoginButtonTag
            createInfoLabel.isHidden = false
        }
        //3 If there is a value within the key 'username' within NSUserdefaults then place it inside the username text field...
        if let storedUsername = UserDefaults.standard.value(forKey: "username") as? String {
            usernameTextField.text = storedUsername
        }
        
    }
    
    func configureUI(){
        let view1 = FBShimmeringView.init()
        view1.backgroundColor = UIColor.clear
        view1.heightAnchor.constraint(equalToConstant: 60).isActive = true
        view1.widthAnchor.constraint(equalToConstant: 360).isActive = true
        stackView.insertArrangedSubview(view1, at: 0)
        let braceletOneLabel = UILabel.init(frame: CGRect.init(x: view1.frame.origin.x, y: view1.frame.origin.y, width: 340, height: 71))
        braceletOneLabel.text = "Bracelet One"
        braceletOneLabel.font = UIFont.init(name: "Helvetica Neue", size: 60)
        braceletOneLabel.font = UIFont.systemFont(ofSize: 60, weight: .thin)
        braceletOneLabel.adjustsFontSizeToFitWidth = true
        braceletOneLabel.textColor = UIColor.white
        braceletOneLabel.textAlignment = .center
        view1.contentView = braceletOneLabel
        view1.isShimmering = true
        view1.shimmeringSpeed = 120
        loginButton.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 20, bottom: 0, right: 20)
        loginButtonFacebook.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 20, bottom: 0, right: 20)
        loginButtonGoogle.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @IBAction func touchIDLoginAction(_ sender: Any) {
        print("TouchID tapped...")
    }
}

// MARK: - IBActions
extension LoginViewController {
    
    @IBAction func loginAction(sender: UIButton) {
        
        guard let newAccountName = usernameTextField.text,
        let newPassword = passwordTextField.text,
        !newAccountName.isEmpty,
            !newPassword.isEmpty else {
                showLoginFailAlert()
                return
        }
        
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        if sender.tag == createLoginButtonTag {
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
            performSegue(withIdentifier: "dismissLogin", sender: self)
        }else if sender.tag == loginButtonTag{
            //7
            if checkLogin(username: newAccountName, password: newPassword){
                performSegue(withIdentifier: "dismissLogin", sender: self)
            }else{
                //8
                showLoginFailAlert()
            }
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
    
    
}
