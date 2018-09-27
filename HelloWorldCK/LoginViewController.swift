/// Copyright (c) 2017 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import CoreData
import Shimmer

class LoginViewController: UIViewController {
    
    // MARK: Properties
    var managedObjectContext: NSManagedObjectContext?
    
    @IBOutlet var stackView: UIStackView!
    // MARK: - IBOutlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var createInfoLabel: UILabel!
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var loginButtonFacebook: UIButton!
    @IBOutlet var loginButtonGoogle: UIButton!
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
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
}

// MARK: - IBActions
extension LoginViewController {
    
    @IBAction func loginAction(sender: Any) {
        performSegue(withIdentifier: "dismissLogin", sender: self)
    }
}
