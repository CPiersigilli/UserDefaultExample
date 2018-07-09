//
//  SS_Alert.swift
//  UserDefaultExample
//
//  Created by Marco Piersigilli on 30/06/18.
//  Copyright © 2018 studiopiersigilli.it. All rights reserved.
//

//
//  SS_Alert.swift
//  SiouxSoft
//
//  Created by Blake Martin on 5/13/18.
//  Copyright © 2018 Blake Martin. All rights reserved.
//
import UIKit

class SS_Alert {
    
    // Notification
    class func displayNotification(parmTitle: String, parmMessage: String) {
        let alert = UIAlertController(title: parmTitle, message: parmMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        displayAlert(parmAlert: alert)
    }
    
    
    // Create Alert
    //  parmTitle: Alert Title
    //  parmMessage: Alert Message
    //  parmOption: Option to select
    //  parmFunctions: Function to perform for option selected
    class func createAlert(parmTitle: String, parmMessage: String, parmOptions: [String], parmFunctions: [(()->())?] ) {
        
//        let alert = UIAlertController(title: parmTitle, message: parmMessage, preferredStyle: UIAlertControllerStyle.alert)
        let alert = UIAlertController(title: parmTitle, message: parmMessage, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let arrayCount = parmOptions.count
        switch arrayCount {
            
        case 1:
            alert.addAction(UIAlertAction(title: parmOptions[0],
                                          style: .default,
                                          handler: {(alert: UIAlertAction!) in self.funcHandler(f: parmFunctions[0])}))
            displayAlert(parmAlert: alert)
        case 2:
            alert.addAction(UIAlertAction(title: parmOptions[0],
                                          style: .destructive,
                                          handler: {(alert: UIAlertAction!) in self.funcHandler(f: parmFunctions[0])}))
            alert.addAction(UIAlertAction(title: parmOptions[1],
                                          style: .cancel,
                                          handler: {(alert: UIAlertAction!) in self.funcHandler(f: parmFunctions[1])}))
            alert.view.tintColor = .blue
            displayAlert(parmAlert: alert)
        case 3:
            alert.addAction(UIAlertAction(title: parmOptions[0],
                                          style: .default,
                                          handler: {(alert: UIAlertAction!) in self.funcHandler(f: parmFunctions[0])}))
            alert.addAction(UIAlertAction(title: parmOptions[1],
                                          style: .default,
                                          handler: {(alert: UIAlertAction!) in self.funcHandler(f: parmFunctions[1])}))
            alert.addAction(UIAlertAction(title: parmOptions[2],
                                          style: .default,
                                          handler: {(alert: UIAlertAction!) in self.funcHandler(f: parmFunctions[2])}))
            displayAlert(parmAlert: alert)
        default:
            displayNotification(parmTitle: "ERROR", parmMessage: "The function (CreateAlert) does not support more than 3 options!")
        }
        
        
    }
    
    
    // Display Alert
    class func displayAlert(parmAlert: UIAlertController) {
        if let activeVC = UIApplication.topViewController() {
            activeVC.present(parmAlert, animated: true)
        }
    }
    
    
    // Function Wrapper
    class func funcHandler(f:(()->())?) {
        f?()
    }
    
    
}
