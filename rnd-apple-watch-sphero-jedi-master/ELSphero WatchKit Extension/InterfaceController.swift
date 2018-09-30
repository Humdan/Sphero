//
//  InterfaceController.swift
//  ELSphero WatchKit Extension
//
//  Created by Dmitriy on 1/11/16.
//  Copyright © 2016 Dmitriy. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion
import WatchConnectivity

enum States:Int{
    case back = 0, stop, right, left, direct
}

class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var labelX: WKInterfaceLabel!
    @IBOutlet weak var labelY: WKInterfaceLabel!
    @IBOutlet weak var labelZ: WKInterfaceLabel!
    @IBOutlet weak var labelState: WKInterfaceLabel!
    @IBOutlet weak var labelCount: WKInterfaceLabel!
    let motionManager = CMMotionManager()

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        motionManager.accelerometerUpdateInterval = 0.5
    }
    
    override func willActivate() {
        super.willActivate()
        
        var state:States = States.back
        var prevState:States = States.back
        let count: Int = 0
        
        if (motionManager.isAccelerometerAvailable == true) {
            let handler:CMAccelerometerHandler = {
                (data: CMAccelerometerData?, error: NSError?) -> Void in
                self.labelX.setText(String(format: "%.2f", data!.acceleration.x))
                self.labelY.setText(String(format: "%.2f", data!.acceleration.y))
                self.labelZ.setText(String(format: "%.2f", data!.acceleration.z))
                
                //Change the state if needed
                if data!.acceleration.x >= 0.85 {
                    prevState = state
                    state = States.back
                }
                else if data!.acceleration.x <= -0.85{
                    prevState = state
                    state = States.stop
                }
                else if data!.acceleration.y >= 0.85{
                    prevState = state
                    state = States.right
                }
                else if data!.acceleration.y <= -0.85{
                    prevState = state
                    state = States.left
                }
                else if abs(data!.acceleration.z) >= 0.85{
                    prevState = state
                    state = States.direct
                }
                
                // Send the message if the state changed
                if state == States.back && prevState != States.back {
                    self.sendMessage("Back")
                }
                else if state == States.stop && prevState != States.stop{
                    self.sendMessage("Stop")
                }
                else if state == States.right && prevState != States.right{
                    self.sendMessage("Right")
                }
                else if state == States.left && prevState != States.left{
                    self.sendMessage("Left")
                }
                else if state == States.direct && prevState != States.direct{
                    self.sendMessage("Direct")
                }
                
                self.labelState.setText(String(format: "%i", state.rawValue))
                self.labelCount.setText(String(format: "%i",count))

            } as! CMAccelerometerHandler
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: handler)
        }
        else {
            self.labelX.setText("not available")
            self.labelY.setText("not available")
            self.labelZ.setText("not available")
        }
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        
        motionManager.stopAccelerometerUpdates()
    }
    
    
    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activate()
            }
        }
    }

    func sendMessage(_ direction:String){
        
        session = WCSession.default()
        
        if session == nil{
            self.sendMessage(direction)
            return
        }
    
        session!.sendMessage(["direction": direction], replyHandler: { (response) -> Void in

        },
        errorHandler: { (error) -> Void in
            
                print(error)
                self.sendMessage(direction)
        })
    }

}

extension InterfaceController: WCSessionDelegate {
    
}
