//
//  Utility.swift
//  UserDefaultExample
//
//  Created by Marco Piersigilli on 11/02/18.
//  Copyright © 2018 studiopiersigilli.it. All rights reserved.
//

import Foundation

//   Funzione che assegna il nome al media da salvare
func mediaName(nomeCartella:String) -> String {
    let nowTime = Date()
    let nowTimeString=nowTime.toString(format: .custom(dateFormatMediaName))
    let mediaName = nomeCartella + "_" + nowTimeString + ".jpg"
    print("MediaName: \(mediaName)")
    return mediaName
}

//   Funzione che verifica la presenza di connessione internet (Wi-Fi o 4G)
func ifReachability() -> Bool {
    let reach = Reachability()
    if reach!.connection != .none {
        print("Reach: \(reach!.connection)")
        return true
    }
    return false
}

//   Rotella infinita
func showIndicatorIndeterminate (view:UIView, label:String, detailLabel:String) -> MBProgressHUD {
    let hud = MBProgressHUD.showAdded(to: view, animated: true)
    hud.mode = .indeterminate
    hud.label.text = label
    hud.detailsLabel.text = detailLabel
    //        indicator.isUserInteractionEnabled = false
    return hud
}

//   Ciambella incrementale
func showIndicatorAnular (view:UIView, label:String, detailLabel:String) -> MBProgressHUD {
    let hud = MBProgressHUD.showAdded(to: view, animated: true)
    hud.mode = .annularDeterminate
    hud.label.text = label
    hud.detailsLabel.text = detailLabel
    //        indicator.isUserInteractionEnabled = false
    return hud
}

//   Ciambella incrementale ViewController
func showIndicatorAnularVC (viewController:UIViewController, label:String, detailLabel:String) -> MBProgressHUD {
    let hud = MBProgressHUD.showAdded(to: viewController.view, animated: true)
    hud.mode = .annularDeterminate
    hud.label.text = label
    hud.detailsLabel.text = detailLabel
    //        indicator.isUserInteractionEnabled = false
    return hud
}

func showFailed(vc: UIViewController, hud: MBProgressHUD, label:String, detailLabel:String) {
    hud.isUserInteractionEnabled = false
    hud.hide(animated: true)
    let hud1 = MBProgressHUD.showAdded(to: vc.view, animated: true)
    hud1.customView = UIImageView(image: UIImage(named: "Failure"))
    hud1.mode = .customView
    hud1.label.text = label
    hud1.detailsLabel.text = detailLabel
    hud1.hide(animated: true, afterDelay: 1.5) //Secondi
}

func showSucceeded(vc: UIViewController, hud: MBProgressHUD, label:String, detailLabel:String) {
    hud.isUserInteractionEnabled = false
    hud.hide(animated: true)
    let hud1 = MBProgressHUD.showAdded(to: vc.view, animated: true)
    hud1.customView = UIImageView(image: UIImage(named: "Success"))
    hud1.mode = .customView
    hud1.label.text = label
    hud1.detailsLabel.text = detailLabel
    hud1.hide(animated: true, afterDelay: 1.5) //Secondi
}


