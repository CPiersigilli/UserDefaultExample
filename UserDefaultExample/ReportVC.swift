//
//  ReportVC.swift
//  UserDefaultExample
//
//  Created by Marco Piersigilli on 18/02/18.
//  Copyright © 2018 studiopiersigilli.it. All rights reserved.
//

import Foundation
import UIKit

class ReportVC: UIViewController {
    
    @IBOutlet weak var logReport: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("ReportVC: viewDidLoad")
        logw("ReportVC: viewDidLoad")
        logReport.text = logr()
    }
}
