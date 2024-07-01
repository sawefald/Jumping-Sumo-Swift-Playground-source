//
//  DroneViewControllerBase.swift
//  UserModule
//
//  Created by Sarah Miller on 6/8/24.
//

import UIKit
import PlaygroundSupport

fileprivate var count = 0

/// Abstract class for all drone views
public class DroneViewControllerBase: UIViewController, PlaygroundLiveViewSafeAreaContainer {

    @IBOutlet var connect: UIButton!
    @IBOutlet var opLabel: UILabel!
    
    fileprivate (set) var liveViewConnectionOpened = false

    // latest operation error
    fileprivate(set) var latestError: DroneController.OpError?

    /// drone controller
    let droneController = DroneController()
    /// motion tracker
    fileprivate let motionTracker = MotionTracker()
    
    @IBAction func connectButton(sender: UIButton) {
        print ("count: \(count) drone state: \(droneController.connectionState)")
        count += 1
        if droneController.connectionState == .disconnected {
            droneController.start()
            sender.setTitle("Connecting...", for: .normal)
        }
        else if droneController.connectionState == .connected {
            droneController.disconnect()
            sender.setTitle("Connect", for: .normal)
        }
        opLabel.text = "Button Pressed"
        opLabel.isHidden = false
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        droneController.delegate = self
        motionTracker.delegate = self
        //btView = PlaygroundBluetoothConnectionView(centralManager: droneController.ble.btManager)
        //view.addSubview(btView!)

        //if myDrone != nil {
            //if !droneController.ble.btManager.connectToLastConnectedPeripheral() {
            //    myDrone = nil
            //}
        //}
        updateContent()
    }

    func updateContent() {
//        if let peripheral = droneController.ble.peripheral {
//            switch droneController.batteryLevel {
//            case .unknown:
//                btView?.setBatteryLevel(nil, forPeripheral: peripheral)
//            case .level(let percent, _):
//                btView?.setBatteryLevel(Double(percent)/100.0, forPeripheral: peripheral)
//            }
//        }
    }

    fileprivate final func sendConnectionStatus() {
        DispatchQueue.main.async {
            if self.droneController.connectionState == .connected {
                self.connect.setTitle("Disconnect", for: .normal)
            }
        }

        send(event: .connected(droneController.connectionState == .connected))
    }

    fileprivate final func sendStatus() {
        send(event: .status)
    }
}

/// Handle drone controller events
extension DroneViewControllerBase: DroneControllerDelegate {

    final func droneControllerDidFindDrone(droneModel: String) {
        DispatchQueue.main.async {
            self.updateContent()
        }
    }

    func droneControllerDidStop() {
        latestError = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.updateContent()
        }
    }

    func droneFirmwareOutOfDate() {
        //DispatchQueue.main.async {
            //if let peripheral = self.droneController.ble.peripheral {
            //    self.btView?.setFirmwareStatus(.outOfDate, forPeripheral: peripheral)
            //}
        //}
    }

    final func droneControllerConnectionStateDidChange(_ connectionState: DroneController.ConnectionState) {
        sendStatus()
        sendConnectionStatus()
        DispatchQueue.main.async {
            self.updateContent()
        }
    }

    final func droneControllerStateDidChange() {
        sendStatus()
        DispatchQueue.main.async {
            self.updateContent()
        }
    }

    final func opTerminated(error: DroneController.OpError?) {
        if let error = error {
            latestError = error
            DispatchQueue.main.async {
                self.updateContent()
            }
        }
        sendStatus()
        send(event: .cmdCompleted)
    }

    func motionTrackerStarted() {
    }

    func motiontrackerUpdate(lateralAngle: Int, longitudinalAngle: Int, lastEvent: MotionEvent) {
    }

    func motionTrackerEvent(_ event: MotionEvent) {
    }
}

extension DroneViewControllerBase: MotionTrackerDelegate {

    final func motionUpdate(lateralAngle: Int, longitudinalAngle: Int, lastEvent: MotionEvent) {
    }

    final func motionEvent(_ event: MotionEvent) {
        send(event: .motionEvent(event: event))
    }
}

extension DroneViewControllerBase: PlaygroundLiveViewMessageHandler {

    final  public func liveViewMessageConnectionOpened() {
        liveViewConnectionOpened = true
        latestError = nil
        updateContent()
    }

    final  public func liveViewMessageConnectionClosed() {
        liveViewConnectionOpened = false
        droneController.execute(op: .stopMoving)
        motionTracker.stop()
        updateContent()
    }

    final  public func receive(_ message: PlaygroundValue) {
        print("playground receive message: \(message))")
        if let cmd = DroneViewProxy.Cmd(value: message) {
            switch cmd {
            case .getState:
                opLabel.text = "getState"
                send(event: .status)
                send(event: .connected(droneController.connectionState == .connected))
                send(event: .cmdCompleted)
//            case .turn(let angle):
//                droneController.execute(op: .turn(angle: angle))
            case .move(let params, let duration):
                opLabel.text = "move"
                droneController.execute(op: .move(params: params, duration: duration))
            case .stopMoving:
                opLabel.text = "stopmoving"
                droneController.execute(op: .stopMoving)
            case .animate(let animation):
                opLabel.text = "animate"
                droneController.execute(op: .animate(animation: animation))
            case .jump(let jumpType):
                opLabel.text = "Jump"
                if jumpType == .emergency {
                    droneController.execute(op: .emergency)
                }
                else if jumpType == .cancel {
                    droneController.execute(op: .cancel)
                }
                else if jumpType == .load {
                    droneController.execute(op: .load)
                }
                else {
                    droneController.execute(op: .jump(jumpType: jumpType))
                }
            case .startAnimation(let animation):
                opLabel.text = "Start Animation"
                droneController.execute(op: .startAnimation(animation: animation))
            case .stopAnimation:
                opLabel.text = "stop animation"
                droneController.execute(op: .stopAnimation)
            //case .takePicture:
            //    droneController.execute(op: .takePicture)
            case .startMotionTracker:
                motionTracker.start()
                break
            }
        }
        updateContent()
    }

    final  func send(event: DroneViewProxy.Evt) {
        if liveViewConnectionOpened {
            send(event.marshal())
        }
    }
}
