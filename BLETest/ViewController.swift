//
//  ViewController.swift
//  BLETest
//
//  Created by Enkhjargal Gansukh on 10/14/16.
//  Copyright © 2016 Enkhjargal Gansukh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var elapsedTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        BluetoothService.instance.startService()
        BluetoothService.instance.setView(view: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func scanBLE(_ sender: AnyObject) {
        BluetoothService.instance.discoverDevices()
    }
    @IBAction func sendReady(_ sender: AnyObject) {
        BluetoothService.instance.sendReady()
    }
    
    
}

