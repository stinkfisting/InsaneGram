//
//  LoginVC.swift
//  InsaneGram
//
//  Created by Marcus Tam on 3/6/17.
//  Copyright © 2017 Marcus Tam. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()


    
    }

    @IBAction func logInPressed(_ sender: Any) {
        guard emailField.text != "", pwField.text != "" else {return}
        
        //Authenticate with Firebase
        FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: pwField.text!, completion: { (user, error) in

            if let error = error {
                print(error.localizedDescription)
            }
            
            if let user = user {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userVC")
                
                self.present(vc, animated: true, completion: nil)
                
            }

        })
        
    }

}
