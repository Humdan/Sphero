//
//  ViewController.swift
//  ELSphero
//
//  Created by Dmitriy on 1/11/16.
//  Copyright © 2016 Dmitriy. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController {

    @IBOutlet weak var accelerometerLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!

    var robot: RKConvenienceRobot!
    var calibrateHandler: RUICalibrateGestureHandler!
    var updateCount: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.appWillResignActive(_:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.appDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.makeMove(_:)), name: NSNotification.Name(rawValue: "ELSUpdateViewNotification"), object: nil)
        
        updateCount = 0;

        calibrateHandler = RUICalibrateGestureHandler(view: self.viewIfLoaded);
        RKRobotDiscoveryAgent.shared().addNotificationObserver(self, selector: #selector(ViewController.handleRobotStateChangeNotification(_:)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func appWillResignActive(_ note: Notification) {
        RKRobotDiscoveryAgent.disconnectAll()
        stopDiscovery()
    }
    
    func appDidBecomeActive(_ note: Notification) {
        startDiscovery()
    }
    
    func handleRobotStateChangeNotification(_ notification: RKRobotChangedStateNotification) {
        let noteRobot = notification.robot
        
        switch (notification.type) {
        case .connecting:
            NSLog("State change with state: \(notification.type)")
            break
        case .online:
            let conveniencerobot = RKConvenienceRobot(robot: noteRobot);
            
            if (UIApplication.shared.applicationState != .active) {
                conveniencerobot?.disconnect()
            } else {
                self.robot = conveniencerobot;
                accelerometerLabel.text = "robot is online"
                calibrateHandler.robot = self.robot.robot
                self.robot.drive(withHeading: 0.0, andVelocity: 0.0);
            }
            break
        case .disconnected:
            calibrateHandler.robot = nil
            robot = nil;
            startDiscovery()
            break
        default:
            NSLog("State change with state: \(notification.type)")
            break
        }
    }
    
    func startDiscovery() {
        RKRobotDiscoveryAgent.startDiscovery()
    }
    
    func stopDiscovery() {
        RKRobotDiscoveryAgent.stopDiscovery()
    }
    
    func makeMove(_ note: Notification)
    {
        ubpdateScreenInfo("Watch connected",spheroConnection: "")
        let direction: String = note.userInfo!["direction"] as! String
        
        var heading: Float = 0.0
        var velocity: Float = 0.4

        if direction == "Direct" {
            heading = 0.0
        }
        else if direction == "Right"{
            heading = 270.0
        }
        else if direction == "Left"{
            heading = 90.0
        }
        else if direction == "Back"{
            heading = 180.0
        }
        else if direction == "Stop"{
            heading = 0.0
            velocity = 0.0
        }
        
        
        if self.robot != nil {
            updateCount = updateCount + 1;
            robot.drive(withHeading: heading, andVelocity: velocity);
            ubpdateScreenInfo("Watch connected",spheroConnection:"Recieved something \(self.updateCount)")
        }
        else {
            ubpdateScreenInfo("Watch connected",spheroConnection:"robot is nil")
        }
    }
    
    func ubpdateScreenInfo(_ watchConnection:String, spheroConnection:String){
        
        DispatchQueue.main.async {
           
            self.infoLabel.text = watchConnection
            self.accelerometerLabel.text = spheroConnection;
        }
        
    }
}


