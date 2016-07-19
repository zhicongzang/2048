//
//  ViewController.swift
//  2048
//
//  Created by Zhicong Zang on 7/19/16.
//  Copyright © 2016 Zhicong Zang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func StartGame(sender: AnyObject) {
        let game = GameViewController(dimension: 4, threshold: 1000000)
        self.presentViewController(game, animated: true, completion: nil)
    }

}

